import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:batallas_pokemon/controladores/controladora.dart';
import 'package:batallas_pokemon/main.dart';
import 'package:batallas_pokemon/models/base.dart';
import 'package:batallas_pokemon/vistas/seleccion_equipo.dart';


class PantallaBatalla extends StatefulWidget {
  final List<Pokemon> equipoJugador;
  final List<Pokemon> equipoEnemigo;

  const PantallaBatalla({
    super.key,
    required this.equipoJugador,
    required this.equipoEnemigo,
  });

  @override
  State<PantallaBatalla> createState() => _EstadoBatalla();
}

class _EstadoBatalla extends State<PantallaBatalla> {
  int _indiceActivoJugador = 0;
  int _indiceActivoEnemigo = 0;

  late Pokemon _pokemonJugador;
  late Pokemon _pokemonEnemigo;
  late Controladora _controladora;

  final ServicioAudio _audio = ServicioAudio();
  final RepoLog _repoLog = RepoLog();

  late List<ItemBatalla> _mochila;

  final List<String> _registro = [];
  bool _resolviendoTurno = false;
  bool _mostrarAtaques = false;
  bool _mostrarMochila = false;
  bool _mostrarCambio = false;

  @override
  void initState() {
    super.initState();
    
    _mochila = [
      Pocion('Pocion', 20),
      Pocion('Superpocion', 50),
      ItemCuracionEstado('Antidoto', CondicionEstado.poisoned),
      ItemCuracionEstado('Antiquemar', CondicionEstado.burned),
      ItemCuracionEstado('Anticongelante', CondicionEstado.frozen),
      ItemCuracionEstado('Antiparalisis', CondicionEstado.paralyzed),
      Pocion('Hiperpocion', 100),
      ItemCuracionEstado('Cura Total', CondicionEstado.none),
    ];

    _pokemonJugador = widget.equipoJugador[_indiceActivoJugador];
    _pokemonEnemigo = widget.equipoEnemigo[_indiceActivoEnemigo];

    _controladora = Controladora(
      jugador: _pokemonJugador,
      enemigo: _pokemonEnemigo,
      repositorioLog: _repoLog,
    );

    _audio.reproducirTemaBatalla();
  }

  void _agregarLog(List<String> lineas) {
    setState(() {
      _registro.addAll(lineas);
      if (_registro.length > 15) {
        _registro.removeRange(0, _registro.length - 15);
      }
    });
  }

  Future<void> _manejarAccion(Function accionJugador, {required bool esAtaque}) async {
    if (_resolviendoTurno || _batallaTermino) return;

    setState(() {
      _resolviendoTurno = true;
      _ocultarTodosMenus();
    });

    List<String> eventosJugador = [];
    
    try {
      eventosJugador = await accionJugador();
      _agregarLog(eventosJugador);
    } catch (e) {
      _agregarLog(['ERROR: ${e.toString()}']);
    }
    
    final bool enemigoDebilitado = _pokemonEnemigo.estaDebilitado;

    if (esAtaque && !enemigoDebilitado) {
      await _turnoAtaqueIA();
    }

    _chequearFinYCambio();

    List<String> eventosEstado = await _controladora.aplicarDanioEstadoFinTurno();
    _agregarLog(eventosEstado);
    await _repoLog.agregarLog(eventosEstado);

    setState(() {
      _resolviendoTurno = false;
    });
  }

  Future<void> _turnoAtaqueIA() async {
    if (_pokemonEnemigo.estaDebilitado || _pokemonJugador.estaDebilitado) return;

    final Random aleatorio = Random();
    
    final Movimiento movimientoEnemigo = _pokemonEnemigo.movimientos[aleatorio.nextInt(_pokemonEnemigo.movimientos.length)];
    List<String> eventosEnemigos = await _controladora.realizarAtaqueEnemigo(movimientoEnemigo);
    _agregarLog(eventosEnemigos);
  }
  
  void _chequearFinYCambio() {
    if (_pokemonJugador.estaDebilitado) {
      final disponibles = widget.equipoJugador.where((p) => !p.estaDebilitado).toList();
      if (disponibles.isNotEmpty) {
        setState(() {
          _mostrarCambio = true;
          _agregarLog(['¡${_pokemonJugador.nombre} se debilito! Elige un nuevo Pokemon.']);
        });
      }
    }

    if (_pokemonEnemigo.estaDebilitado) {
      final disponibles = widget.equipoEnemigo.where((p) => !p.estaDebilitado).toList();
      if (disponibles.isNotEmpty) {
        final siguienteIndice = widget.equipoEnemigo.indexOf(disponibles.first);
        _cambiarPokemonEnemigo(siguienteIndice);
        _agregarLog(['El rival ha enviado a ${_pokemonEnemigo.nombre}.']);
        
        _turnoAtaqueIA(); 
      }
    }
  }

  Future<List<String>> _cambiarPokemonJugador(int nuevoIndice) async {
    final List<String> registro = [];
    if (widget.equipoJugador[nuevoIndice].estaDebilitado) {
      registro.add('¡${widget.equipoJugador[nuevoIndice].nombre} esta debilitado y no puede combatir!');
      return registro;
    }

    if (nuevoIndice == _indiceActivoJugador) {
      registro.add('${_pokemonJugador.nombre} ya esta en batalla.');
      return registro;
    }

    final nombreAntiguo = _pokemonJugador.nombre;
    _indiceActivoJugador = nuevoIndice;
    _pokemonJugador = widget.equipoJugador[_indiceActivoJugador];

    _controladora.jugador = _pokemonJugador;

    registro.add('${nombreAntiguo} regresa... ¡Adelante, ${_pokemonJugador.nombre}! (Turno de cambio)');

    return registro;
  }

  void _cambiarPokemonEnemigo(int nuevoIndice) {
    if (widget.equipoEnemigo[nuevoIndice].estaDebilitado) return; 

    _indiceActivoEnemigo = nuevoIndice;
    _pokemonEnemigo = widget.equipoEnemigo[_indiceActivoEnemigo];

    _controladora.enemigo = _pokemonEnemigo;
  }


  Future<List<String>> _usarMovimiento(Movimiento movimiento) async {
    return await _controladora.realizarAtaqueJugador(movimiento);
  }

  Future<List<String>> _usarItem(ItemBatalla item) async {
    final List<String> registro = [];

    item.aplicar(_pokemonJugador);
    registro.add('Usaste ${item.nombre} sobre ${_pokemonJugador.nombre}.');
    
    final Type tipoItem = item.runtimeType;

    _mochila.removeWhere((i) => i.runtimeType == tipoItem);

    return registro;
  }
  
  void _ocultarTodosMenus() {
     _mostrarAtaques = false;
     _mostrarMochila = false;
     _mostrarCambio = false;
  }
  
  Widget _construirTarjeta(
    Pokemon p, 
    bool esJugador,
    double anchoTarjeta,
  ) {
    final CrossAxisAlignment alineacion = esJugador ? CrossAxisAlignment.start : CrossAxisAlignment.end;
    
    return Card(
      color: pastelWhite.withOpacity(0.9),
      margin: EdgeInsets.zero,
      child: Container(
        padding: const EdgeInsets.all(8),
        width: anchoTarjeta,
        child: Column(
          crossAxisAlignment: alineacion,
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              crossAxisAlignment: alineacion,
              children: [
                Text(
                  '${p.nombre} - ${esJugador ? 'Tu' : 'Enemigo'}',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                Text('HP: ${p.vidaActual}/${p.vidaMaxima}', style: const TextStyle(fontSize: 12, color: Colors.black54)),
                const SizedBox(height: 2),
                
                Stack(
                  children: [
                    Container(
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.red.shade200, 
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: p.vidaActual / p.vidaMaxima,
                      child: Container(
                        height: 8,
                        decoration: BoxDecoration(
                          color: p.vidaActual > p.vidaMaxima / 2 ? Colors.green.shade500 : Colors.orange.shade400,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
            ),
            
            Text('Tipo: ${p.tipo.nombreMostrar.toUpperCase()}', style: const TextStyle(fontSize: 10, color: Colors.black54)),
            Text('Estado: ${p.estado.nombreMostrar}', style: const TextStyle(fontSize: 10, color: Colors.black54)),
          ],
        ),
      ),
    );
  }

  Widget _construirImagen(Pokemon p, bool esJugador, double tamanio) {
    return Transform.scale(
      scaleX: esJugador ? 1.0 : -1.0, 
      child: Image.asset(
        p.rutaImagen,
        fit: BoxFit.contain,
        height: tamanio,
        errorBuilder: (context, error, stackTrace) {
          return Transform.scale(
            scaleX: esJugador ? 1.0 : -1.0, 
            child: Icon(
              Icons.catching_pokemon, 
              size: tamanio / 2, 
              color: Colors.grey.shade600,
            ),
          );
        },
      ),
    );
  }

  bool get _batallaTermino {
    final conteoJugadorDebilitado = widget.equipoJugador.where((p) => p.estaDebilitado).length;
    final conteoEnemigoDebilitado = widget.equipoEnemigo.where((p) => p.estaDebilitado).length;
    return conteoJugadorDebilitado == widget.equipoJugador.length || conteoEnemigoDebilitado == widget.equipoEnemigo.length;
  }
  
  Widget _buildMainMenu() {
    final bool batallaTerminada = _batallaTermino;

    final bool pokemonActivoJugadorDebilitado = _pokemonJugador.estaDebilitado;
    final bool quedanPokemonJugador = widget.equipoJugador.any((p) => !p.estaDebilitado);

    if (batallaTerminada) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.equipoJugador.every((p) => p.estaDebilitado)
                  ? '¡Tu equipo se debilito! ¡Has perdido!'
                  : '¡El equipo rival se debilito! ¡Has ganado!',
              style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(child: _construirBotonNuevaPartida()), 
                const SizedBox(width: 8),
                Expanded(child: _construirBotonSalir()),
              ],
            ),
          ],
        ),
      );
    }
    
    if (pokemonActivoJugadorDebilitado && quedanPokemonJugador) {
      _mostrarCambio = true;
      return _construirMenuCambio(); 
    }

    return _mostrarAtaques
        ? _construirMenuAtaques()
        : _mostrarMochila
            ? _construirMenuMochila()
            : _mostrarCambio
                ? _construirMenuCambio()
                : _construirBotonesAccion();

  }
  
  Widget _construirBotonesAccion() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: GridView.count(
            crossAxisCount: 2,
            childAspectRatio: 2.5,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            children: [
              ElevatedButton(
                onPressed: _resolviendoTurno || _pokemonJugador.estaDebilitado
                    ? null
                    : () {
                        setState(() {
                          _mostrarAtaques = true;
                          _ocultarOtrosMenus(ataque: true);
                        });
                      },
                child: const Text('LUCHA', style: TextStyle(fontSize: 16)),
              ),
              ElevatedButton(
                onPressed: _resolviendoTurno || _pokemonJugador.estaDebilitado
                    ? null
                    : () {
                        setState(() {
                          _mostrarMochila = true;
                          _ocultarOtrosMenus(mochila: true);
                        });
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: pastelGreen.withOpacity(0.9),
                  foregroundColor: Colors.black87,
                ),
                child: const Text('MOCHILA', style: TextStyle(fontSize: 16)),
              ),
              ElevatedButton(
                onPressed: _resolviendoTurno || _pokemonJugador.estaDebilitado
                    ? null
                    : () {
                        setState(() {
                          _mostrarCambio = true;
                          _ocultarOtrosMenus(cambioPk: true);
                        });
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: pastelBlue.withOpacity(0.9),
                  foregroundColor: Colors.black87,
                ),
                child: const Text('CAMBIAR POKEMON', style: TextStyle(fontSize: 16)),
              ),
              _construirBotonSalir(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _construirBotonSalir() {
    return ElevatedButton(
      onPressed: () => exit(0),
      style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade400, foregroundColor: Colors.black),
      child: const Text('SALIR', style: TextStyle(fontSize: 16)),
    );
  }
  
  Widget _construirBotonNuevaPartida() {
    return ElevatedButton(
      onPressed: () async {
        await _audio.dispose();
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const SeleccionEquipo()),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.lightGreen,
        foregroundColor: Colors.black87,
      ),
      child: const Text('NUEVA PARTIDA', style: TextStyle(fontSize: 16)),
    );
  }
  
  void _ocultarOtrosMenus({bool ataque = false, bool mochila = false, bool cambioPk = false}) {
    if (!ataque) _mostrarAtaques = false;
    if (!mochila) _mostrarMochila = false;
    if (!cambioPk) _mostrarCambio = false;
  }
  
  Widget _construirBotonRegreso() {
    return Align(
      alignment: Alignment.topLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: ElevatedButton.icon(
          onPressed: () {
            setState(() {
              _mostrarAtaques = false;
              _mostrarMochila = false;
              _mostrarCambio = false;
            });
          },
          icon: const Icon(Icons.arrow_back, size: 16, color: Colors.black87),
          label: const Text('Regresar', style: TextStyle(fontSize: 14)),
          style: ElevatedButton.styleFrom(
            backgroundColor: pastelWhite,
            foregroundColor: Colors.black87,
            minimumSize: const Size(100, 30),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          ),
        ),
      ),
    );
  }

  Widget _construirMenuAtaques() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _construirBotonRegreso(),
        const Text('Elige un ataque:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
        const SizedBox(height: 8),
        Expanded(
          child: ListView.builder(
            itemCount: _pokemonJugador.movimientos.length,
            itemBuilder: (context, index) {
              final movimiento = _pokemonJugador.movimientos[index];
              return Card(
                color: pastelOrange.withOpacity(0.7),
                margin: const EdgeInsets.symmetric(vertical: 4),
                child: ListTile(
                  title: Text(movimiento.nombre, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87)),
                  subtitle: Text(
                      'Tipo: ${movimiento.tipo.nombreMostrar.toUpperCase()} | PP: ${movimiento.ppRestante}', 
                      style: const TextStyle(fontSize: 16, color: Colors.black54)
                  ),
                  onTap: _resolviendoTurno
                      ? null
                      : () => _manejarAccion(() => _usarMovimiento(movimiento), esAtaque: true),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
  
  Widget _construirMenuMochila() {
    if (_mochila.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _construirBotonRegreso(),
          const Text('Objetos:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
          const SizedBox(height: 8),
          const Center(child: Text('Mochila vacia', style: TextStyle(color: Colors.black87))),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _construirBotonRegreso(),
        const Text('Objetos:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
        const SizedBox(height: 8),
        Expanded(
          child: ListView.builder(
            itemCount: _mochila.length,
            itemBuilder: (context, index) {
              final item = _mochila[index];
              return Card( 
                color: pastelGreen.withOpacity(0.7),
                margin: const EdgeInsets.symmetric(vertical: 4),
                child: ListTile(
                  title: Text(item.nombre, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87)),
                  subtitle: Text(
                    item.descripcion, 
                    style: const TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                  onTap: _resolviendoTurno
                      ? null
                      : () => _manejarAccion(() => _usarItem(item), esAtaque: false), 
                ),
              );
            },
          ),
        ),
      ],
    );
  }
  
  Widget _construirMenuCambio() {
    final bool esCambioForzado = _pokemonJugador.estaDebilitado;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!esCambioForzado) _construirBotonRegreso(),
        Text(esCambioForzado 
            ? '¡Debes elegir un Pokemon para continuar!' 
            : 'Elige un Pokemon para cambiar:', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
        const SizedBox(height: 8),
        Expanded(
          child: ListView.builder(
            itemCount: widget.equipoJugador.length,
            itemBuilder: (context, index) {
              final pk = widget.equipoJugador[index];
              final estaDebilitado = pk.estaDebilitado;
              final esActual = index == _indiceActivoJugador;
              
              return Card(
                color: estaDebilitado ? Colors.grey.shade400 : pastelBlue.withOpacity(0.7),
                margin: const EdgeInsets.symmetric(vertical: 4),
                child: ListTile(
                  title: Text(pk.nombre, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87)),
                  subtitle: Text(
                    esActual 
                        ? 'Actual' 
                        : estaDebilitado ? 'DEBILITADO' : 'HP: ${pk.vidaActual}/${pk.vidaMaxima}', 
                    style: const TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                  onTap: estaDebilitado || esActual || _resolviendoTurno
                      ? null
                      : () => _manejarAccion(() => _cambiarPokemonJugador(index), esAtaque: false), 
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final double anchoPantalla = MediaQuery.of(context).size.width;
    final double altoPantalla = MediaQuery.of(context).size.height;
    
    final double anchoZonaBatalla = anchoPantalla * 0.70;
    
    final double anchoTarjetaEstado = anchoPantalla * 0.30; 
    
    final double anchoZonaMenu = anchoPantalla * 0.30; 
    
    final double tamanioImagenPokemon = altoPantalla * 0.30;
    const double smallPadding = 5.0; 
    
    final double altoMenuDisponible = altoPantalla - (kToolbarHeight + MediaQuery.of(context).padding.top);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('¡Batalla POKEMON!'),
        actions: const [
        ],
      ),
      body: Row(
        children: [
          Container(
            width: anchoZonaMenu,
            height: altoMenuDisponible,
            padding: const EdgeInsets.all(8),
            color: pastelBlue.withOpacity(0.5),
            child: Column(
              children: [
                Expanded(
                  flex: 1,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: pastelBlue.withOpacity(0.8), 
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.all(8),
                    child: _buildMainMenu(),
                  ),
                ),
                
                Expanded(
                  flex: 3, 
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(8),
                      color: pastelWhite,
                    ),
                    child: ListView(
                      reverse: true,
                      children: _registro.reversed
                          .map((linea) => Text(
                                linea,
                                style: const TextStyle(fontSize: 22, color: Colors.black87),
                              ))
                          .toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          Container(
            width: anchoZonaBatalla,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/img/fondo.png'), 
                fit: BoxFit.cover,
              ),
            ),
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: Container(
                    width: anchoTarjetaEstado,
                    margin: EdgeInsets.only(
                      top: altoPantalla / 2 - tamanioImagenPokemon / 2 - 100,
                      right: 10,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _construirTarjeta(
                          _pokemonEnemigo, 
                          false, 
                          anchoTarjetaEstado
                        ),
                        
                        const SizedBox(height: smallPadding), 
                        
                        _construirImagen(
                          _pokemonEnemigo, 
                          false, 
                          tamanioImagenPokemon
                        ),
                      ],
                    ),
                  ),
                ),
                
                Positioned(
                  left: 10, 
                  bottom: altoPantalla * 0.02,
                  child: _construirImagen(
                    _pokemonJugador, 
                    true, 
                    tamanioImagenPokemon
                  ),
                ),
                
                Positioned(
                  left: 10, 
                  bottom: altoPantalla * 0.02 + tamanioImagenPokemon + smallPadding, 
                  child: _construirTarjeta(
                    _pokemonJugador, 
                    true, 
                    anchoTarjetaEstado
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}