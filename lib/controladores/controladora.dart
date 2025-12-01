import 'dart:async';
import 'dart:math';
import 'package:batallas_pokemon/models/base.dart';
class Controladora {
  Pokemon jugador;
  Pokemon enemigo;

  final EstrategiaDanio _estrategiaDanio = EstrategiaDanioBasadaEnTipo();
  final Random _aleatorio = Random();
  final RepoLog _repositorioLog;

  Controladora({
    required this.jugador,
    required this.enemigo,
    required RepoLog repositorioLog,
  }) : _repositorioLog = repositorioLog;

  Future<List<String>> realizarAtaqueJugador(Movimiento movimientoJugador) async {
    return _resolverTurno(
      atacanteA: jugador, 
      defensorA: enemigo, 
      movimientoA: movimientoJugador, 
      esJugadorA: true,
    );
  }

  Future<List<String>> realizarAtaqueEnemigo(Movimiento movimientoEnemigo) async {
     return _resolverTurno(
      atacanteA: enemigo, 
      defensorA: jugador, 
      movimientoA: movimientoEnemigo, 
      esJugadorA: false,
    );
  }
  
  Future<List<String>> _resolverTurno({
    required Pokemon atacanteA,
    required Pokemon defensorA,
    required Movimiento movimientoA,
    required bool esJugadorA,
  }) async {
    final List<String> _registro = [];

    try {
      if (movimientoA.ppRestante <= 0) {
        throw ExcepcionMovimientoSinPP(movimientoA.nombre);
      }
      
      await _resolverAtaque(
        atacante: atacanteA,
        defensor: defensorA,
        movimiento: movimientoA,
        registro: _registro,
      );
      
    } on ExcepcionMovimientoSinPP catch (e) {
      _registro.add(e.toString());
    } catch (e) {
      _registro.add('Ocurrio un error al resolver el turno.');
    }

    return _registro;
  }

  bool _estaParalizado(Pokemon p) {
    if (p.estado != CondicionEstado.paralyzed) return false;
    final int tirada = _aleatorio.nextInt(5);
    return tirada == 0;
  }

  Future<void> _resolverAtaque({
    required Pokemon atacante,
    required Pokemon defensor,
    required Movimiento movimiento,
    required List<String> registro,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    if (atacante.estaDebilitado) return;

    if (atacante.estado == CondicionEstado.paralyzed && _estaParalizado(atacante)) {
      registro.add('${atacante.nombre} esta paralizado y no se puede mover.');
      return;
    }

    if (movimiento.ppRestante <= 0) {
      registro.add('${atacante.nombre} no tiene PP para ${movimiento.nombre}.');
      return;
    }
    movimiento.ppRestante--;

    if (_aleatorio.nextDouble() > movimiento.precision) {
      registro.add('${atacante.nombre} fallo el ataque ${movimiento.nombre}.');
      return;
    }

    final double _stab = (movimiento.tipo == atacante.tipo) ? 1.5 : 1.0;
    final double _efectividad =
        _estrategiaDanio.efectividad(movimiento.tipo, defensor.tipo);
    final double _variacion = 0.85 + _aleatorio.nextDouble() * 0.15;

    double _danioBruto = movimiento.poder.toDouble();
    _danioBruto *= _stab * _efectividad * _variacion;

    final int _danioFinal = max(1, _danioBruto.round());
    defensor.recibirDanio(_danioFinal);

    String _texto = '${atacante.nombre} uso ${movimiento.nombre}. ';
    if (_efectividad == 0.0) {
      _texto += 'El ataque no hizo efecto. ';
    } else if (_efectividad > 1.0) {
      _texto += '¡Es super efectivo! ';
    } else if (_efectividad < 1.0 && _efectividad > 0.0) {
      _texto += 'No es muy efectivo... ';
    } 
    
    if (_danioFinal > 0) {
      _texto += 'Causo $_danioFinal de danio.';
    }
    
    registro.add(_texto);

    if (movimiento.estadoAInfigir != null &&
        !_esInmuneEstado(defensor, movimiento.estadoAInfigir!) &&
        defensor.estado == CondicionEstado.none) {
      if (_aleatorio.nextDouble() < movimiento.probabilidadEstado) {
        defensor.estado = movimiento.estadoAInfigir!;
        registro.add('${defensor.nombre} ahora esta ${defensor.estado.nombreMostrar}.');
      }
    }
  }

  bool _esInmuneEstado(Pokemon defensor, CondicionEstado estado) {
    if (estado == CondicionEstado.paralyzed && defensor.tipo == TipoPokemon.electric) return true;
    return false;
  }

  Future<List<String>> aplicarDanioEstadoFinTurno() async {
    final List<String> _registro = [];
    await Future.delayed(const Duration(milliseconds: 300));

    int _danioJugador = jugador.aplicarDanioEstadoFinTurno();
    int _danioEnemigo = enemigo.aplicarDanioEstadoFinTurno();

    if (_danioJugador > 0) {
      _registro.add(
          '${jugador.nombre} sufre $_danioJugador de danio por su estado (${jugador.estado.nombreMostrar}).');
    }
    if (_danioEnemigo > 0) {
      _registro.add(
          '${enemigo.nombre} sufre $_danioEnemigo de danio por su estado (${enemigo.estado.nombreMostrar}).');
    }
    
    return _registro;
  }
}