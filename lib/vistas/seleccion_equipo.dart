import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:batallas_pokemon/main.dart';
import 'package:batallas_pokemon/models/base.dart';
import 'package:batallas_pokemon/models/catalogo.dart';
import 'package:batallas_pokemon/vistas/pantalla_batalla.dart';

class SeleccionEquipo extends StatefulWidget {
  const SeleccionEquipo({super.key});

  @override
  State<SeleccionEquipo> createState() => _EstadoSeleccionEquipo();
}

class _EstadoSeleccionEquipo extends State<SeleccionEquipo> {
  final List<Pokemon> _catalogo = crearCatalogoPokemon();
  final List<Pokemon> _equipoSeleccionado = [];

  void _seleccionar(Pokemon pokemon) {
    setState(() {
      if (_equipoSeleccionado.contains(pokemon)) {
        _equipoSeleccionado.remove(pokemon);
      } else if (_equipoSeleccionado.length < 3) {
        _equipoSeleccionado.add(pokemon);
      }
    });
  }

  void _iniciarBatalla() {
    if (_equipoSeleccionado.length != 3) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: const Text('Debes seleccionar exactamente 3 Pokemon.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    final List<Pokemon> catalogoClonado = crearCatalogoPokemon();
    
    final List<Pokemon> reservaEnemiga = catalogoClonado
        .where((p) => !_equipoSeleccionado.any((s) => s.nombre == p.nombre))
        .toList();
    
    final Random aleatorio = Random();
    final List<Pokemon> equipoEnemigo = [];
    
    List<Pokemon> reservaTemporal = List.from(reservaEnemiga);

    for (int i = 0; i < 3; i++) {
      if (reservaTemporal.isEmpty) break;
      int indice = aleatorio.nextInt(reservaTemporal.length);
      equipoEnemigo.add(reservaTemporal[indice]);
      reservaTemporal.removeAt(indice);
    }
    
    final List<Pokemon> clonesEquipoJugador = _equipoSeleccionado.map((p) => p.clonar()).toList();


    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => PantallaBatalla(
          equipoJugador: clonesEquipoJugador,
          equipoEnemigo: equipoEnemigo,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Selecciona tu Equipo (3 Pokemon)'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
            child: GestureDetector(
              onTap: () => exit(0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.red.shade600,
                  borderRadius: BorderRadius.circular(4),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: const Text(
                  'SALIR',
                  style: TextStyle(
                    fontSize: 16, 
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Seleccionados: ${_equipoSeleccionado.length} / 3',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 0.9,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: _catalogo.length,
              itemBuilder: (context, index) {
                final pokemon = _catalogo[index];
                final esSeleccionado = _equipoSeleccionado.contains(pokemon);
                
                Color colorTipo;
                switch (pokemon.tipo) {
                  case TipoPokemon.grass:
                  case TipoPokemon.bug:
                    colorTipo = pastelGreen;
                    break;
                  case TipoPokemon.fire:
                  case TipoPokemon.fighting:
                    colorTipo = pastelOrange;
                    break;
                  case TipoPokemon.water:
                  case TipoPokemon.ice:
                  case TipoPokemon.flying:
                    colorTipo = pastelBlue;
                    break;
                  case TipoPokemon.electric:
                  case TipoPokemon.ground:
                    colorTipo = pastelYellow;
                    break;
                  case TipoPokemon.fairy:
                  case TipoPokemon.poison:
                    colorTipo = pastelPink;
                    break;
                  default:
                    colorTipo = pastelWhite;
                }

                return GestureDetector(
                  onTap: () => _seleccionar(pokemon),
                  child: Card(
                    color: pastelWhite,
                    elevation: esSeleccionado ? 8 : 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: esSeleccionado
                          ? BorderSide(color: colorTipo, width: 4)
                          : BorderSide(color: Colors.grey.shade300, width: 1),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: colorTipo.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Image.asset(
                                pokemon.rutaImagen,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(
                                    Icons.catching_pokemon, 
                                    size: 40,
                                    color: Colors.grey.shade600,
                                  ); 
                                },
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0, top: 4.0),
                            child: Text(
                              '${pokemon.nombre}\n(${pokemon.tipo.nombreMostrar.toUpperCase()})',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12, 
                                fontWeight: FontWeight.bold,
                                color: esSeleccionado ? Colors.black : Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: _iniciarBatalla,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: primaryButtonColor,
                foregroundColor: Colors.black,
              ),
              child: const Text(
                '¡COMENZAR BATALLA!',
                style: TextStyle(fontSize: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }
}