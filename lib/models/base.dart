import 'dart:async';
import 'dart:math';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class ServicioAudio {
  final AudioPlayer _bgm = AudioPlayer();

  Future<void> reproducirTemaBatalla() async {
    try {
      await _bgm.setReleaseMode(ReleaseMode.loop);
      await _bgm.play(AssetSource('audio/battle_theme.mp3'));
    } catch (e) {
    }
  }

  Future<void> dispose() async {
    try {
      await _bgm.stop();
      await _bgm.dispose();
    } catch (e) {
      // Ignoramos el error para que la aplicación no se congele 
      // si se llama dispose() dos veces o si el reproductor ya está en un estado inválido.
      debugPrint('Error seguro al liberar AudioPlayer: $e');
    }
  }
}

class RepoLog {
  Future<File> _obtenerArchivo() async {
    final dir = await getApplicationDocumentsDirectory();
    final path = '${dir.path}/registro_batalla.txt';
    return File(path);
  }

  Future<void> agregarLog(List<String> lineas) async {
    try {
      final archivo = await _obtenerArchivo();
      final ahora = DateTime.now().toLocal().toString().substring(11, 19);
      final texto = lineas.map((linea) => '[$ahora] $linea').join('\n') + '\n';
      await archivo.writeAsString(texto, mode: FileMode.append, flush: true);
    } catch (e) {
    }
  }
}

enum TipoPokemon {
  normal, fire, water, grass, electric, ice, fighting, poison, ground, flying,
  psychic, bug, rock, ghost, dragon, dark, steel, fairy,
}

extension ExtTipo on TipoPokemon {
  String get nombreMostrar {
    switch (this) {
      case TipoPokemon.normal: return 'Normal';
      case TipoPokemon.fire: return 'Fuego';
      case TipoPokemon.water: return 'Agua';
      case TipoPokemon.grass: return 'Planta';
      case TipoPokemon.electric: return 'Electrico';
      case TipoPokemon.ice: return 'Hielo';
      case TipoPokemon.fighting: return 'Lucha';
      case TipoPokemon.poison: return 'Veneno';
      case TipoPokemon.ground: return 'Tierra';
      case TipoPokemon.flying: return 'Volador';
      case TipoPokemon.psychic: return 'Psiquico';
      case TipoPokemon.bug: return 'Bicho';
      case TipoPokemon.rock: return 'Roca';
      case TipoPokemon.ghost: return 'Fantasma';
      case TipoPokemon.dragon: return 'Dragon';
      case TipoPokemon.dark: return 'Siniestro';
      case TipoPokemon.steel: return 'Acero';
      case TipoPokemon.fairy: return 'Hada';
    }
  }
}

enum CondicionEstado { none, poisoned, burned, frozen, paralyzed }

extension ExtEstado on CondicionEstado {
  String get nombreMostrar {
    switch (this) {
      case CondicionEstado.none:
        return 'OK';
      case CondicionEstado.poisoned:
        return 'Envenenado';
      case CondicionEstado.burned:
        return 'Quemado';
      case CondicionEstado.frozen:
        return 'Congelado';
      case CondicionEstado.paralyzed:
        return 'Paralizado';
    }
  }
}

class Movimiento {
  final String nombre;
  final TipoPokemon tipo;
  final int poder;
  final double precision;
  int ppRestante;
  final int ppMaximoInicial; // Almacena el valor original de PP máximo

  final CondicionEstado? estadoAInfigir;
  final double probabilidadEstado;

  Movimiento({
    required this.nombre,
    required this.tipo,
    required this.poder,
    required this.precision,
    this.estadoAInfigir,
    this.probabilidadEstado = 0.0,
    required int ppMaximo,
    int? ppInicial, // Usado para la clonación, para restablecer los PP usados
  }) : 
    ppRestante = ppInicial ?? ppMaximo,
    ppMaximoInicial = ppMaximo;
  
  Movimiento clonar() {
    // Clonamos manteniendo el PP Máximo y el PP Restante (para el estado de juego)
    return Movimiento(
      nombre: nombre,
      tipo: tipo,
      poder: poder,
      precision: precision,
      estadoAInfigir: estadoAInfigir,
      probabilidadEstado: probabilidadEstado,
      ppMaximo: ppMaximoInicial, // Pasa el PP Máximo real
      ppInicial: ppRestante,     // Pasa el PP Restante como el valor inicial para el clon
    );
  }
}

class Pokemon {
  final String nombre;
  final TipoPokemon tipo;
  final int vidaMaxima;
  int vidaActual;
  final int velocidad;
  final String rutaImagen;
  
  final List<Movimiento> movimientos; 
  CondicionEstado estado;

  Pokemon({
    required this.nombre,
    required this.tipo,
    required this.vidaMaxima,
    required this.velocidad,
    required this.rutaImagen,
    required List<Movimiento> movimientos,
    this.estado = CondicionEstado.none,
  }) : vidaActual = vidaMaxima, movimientos = movimientos.map((m) => m.clonar()).toList();

  bool get estaDebilitado => vidaActual <= 0;

  int get velocidadEfectiva {
    if (estado == CondicionEstado.paralyzed) {
      return max(1, velocidad ~/ 2);
    }
    return velocidad;
  }

  void recibirDanio(int cantidad) {
    vidaActual = max(0, vidaActual - cantidad);
  }

  void curar(int cantidad) {
    vidaActual = min(vidaMaxima, vidaActual + cantidad);
  }

  void curarEstado(CondicionEstado estadoACurar) {
    if (estado == estadoACurar) {
      estado = CondicionEstado.none;
    }
  }

  void curarTodosEstados() {
    estado = CondicionEstado.none;
  }

  int aplicarDanioEstadoFinTurno() {
    int danio = 0;
    if (estado == CondicionEstado.poisoned ||
        estado == CondicionEstado.burned) {
      danio = max(1, vidaMaxima ~/ 16);
      recibirDanio(danio);
    }
    return danio;
  }
  
  Pokemon clonar() {
    return Pokemon(
      nombre: nombre,
      tipo: tipo,
      vidaMaxima: vidaMaxima,
      velocidad: velocidad,
      rutaImagen: rutaImagen,
      movimientos: _crearMovimientosParaClon(movimientos),
      estado: estado,
    );
  }
  
  static List<Movimiento> _crearMovimientosParaClon(List<Movimiento> movimientosOriginales) {
    return movimientosOriginales.map((m) => Movimiento(
      nombre: m.nombre,
      tipo: m.tipo,
      poder: m.poder,
      precision: m.precision,
      estadoAInfigir: m.estadoAInfigir,
      probabilidadEstado: m.probabilidadEstado,
      ppMaximo: m.ppMaximoInicial, // Usa el máximo original
      ppInicial: m.ppRestante,     // Mantiene el ppRestante actual
    )).toList();
  }
}

class ExcepcionMovimientoSinPP implements Exception {
  final String nombreMovimiento;

  ExcepcionMovimientoSinPP(this.nombreMovimiento);

  @override
  String toString() => 'No quedan PP para $nombreMovimiento.';
}

// ------------------------------------------------------------
// CLASES DE ITEMS (AÑADIDAS)
// ------------------------------------------------------------

abstract class ItemBatalla {
  final String nombre;
  String get descripcion;
  
  ItemBatalla(this.nombre);
  
  void aplicar(Pokemon pokemon);
}

class Pocion extends ItemBatalla {
  final int cantidadCuracion;

  Pocion(String nombre, this.cantidadCuracion) : super(nombre);

  @override
  String get descripcion => 'Restaura $cantidadCuracion HP.';
  
  @override
  void aplicar(Pokemon pokemon) {
    pokemon.curar(cantidadCuracion);
  }
}

class ItemCuracionEstado extends ItemBatalla {
  final CondicionEstado estadoACurar;

  ItemCuracionEstado(String nombre, this.estadoACurar) : super(nombre);

  @override
  String get descripcion {
    if (estadoACurar == CondicionEstado.none) {
      return 'Cura todos los problemas de estado.';
    }
    return 'Cura el estado ${estadoACurar.nombreMostrar}.';
  }
  
  @override
  void aplicar(Pokemon pokemon) {
    if (estadoACurar == CondicionEstado.none) {
      pokemon.curarTodosEstados();
    } else {
      pokemon.curarEstado(estadoACurar);
    }
  }
}

// ------------------------------------------------------------


abstract class EstrategiaDanio {
  double efectividad(TipoPokemon tipoAtaque, TipoPokemon tipoDefensa);
}

class EstrategiaDanioBasadaEnTipo implements EstrategiaDanio {
  static const Map<TipoPokemon, Map<TipoPokemon, double>> _tabla = {
    TipoPokemon.normal: {
      TipoPokemon.rock: 0.5,
      TipoPokemon.steel: 0.5,
      TipoPokemon.ghost: 0.0,
    },
    TipoPokemon.fire: {
      TipoPokemon.grass: 2.0,
      TipoPokemon.ice: 2.0,
      TipoPokemon.bug: 2.0,
      TipoPokemon.steel: 2.0,
      TipoPokemon.rock: 0.5,
      TipoPokemon.fire: 0.5,
      TipoPokemon.water: 0.5,
      TipoPokemon.dragon: 0.5,
    },
    TipoPokemon.water: {
      TipoPokemon.fire: 2.0,
      TipoPokemon.ground: 2.0,
      TipoPokemon.rock: 2.0,
      TipoPokemon.water: 0.5,
      TipoPokemon.grass: 0.5,
      TipoPokemon.dragon: 0.5,
    },
    TipoPokemon.grass: {
      TipoPokemon.water: 2.0,
      TipoPokemon.ground: 2.0,
      TipoPokemon.rock: 2.0,
      TipoPokemon.flying: 0.5,
      TipoPokemon.poison: 0.5,
      TipoPokemon.bug: 0.5,
      TipoPokemon.steel: 0.5,
      TipoPokemon.fire: 0.5,
      TipoPokemon.grass: 0.5,
      TipoPokemon.dragon: 0.5,
    },
    TipoPokemon.electric: {
      TipoPokemon.water: 2.0,
      TipoPokemon.flying: 2.0,
      TipoPokemon.grass: 0.5,
      TipoPokemon.electric: 0.5,
      TipoPokemon.ground: 0.0,
    },
    TipoPokemon.ice: {
      TipoPokemon.grass: 2.0,
      TipoPokemon.ground: 2.0,
      TipoPokemon.flying: 2.0,
      TipoPokemon.dragon: 2.0,
      TipoPokemon.steel: 0.5,
      TipoPokemon.fire: 0.5,
      TipoPokemon.water: 0.5,
      TipoPokemon.ice: 0.5,
    },
    TipoPokemon.fighting: {
      TipoPokemon.normal: 2.0,
      TipoPokemon.ice: 2.0,
      TipoPokemon.rock: 2.0,
      TipoPokemon.steel: 2.0,
      TipoPokemon.dark: 2.0,
      TipoPokemon.flying: 0.5,
      TipoPokemon.poison: 0.5,
      TipoPokemon.bug: 0.5,
      TipoPokemon.psychic: 0.5,
      TipoPokemon.fairy: 0.5,
      TipoPokemon.ghost: 0.0,
    },
    TipoPokemon.ground: {
      TipoPokemon.fire: 2.0,
      TipoPokemon.electric: 2.0,
      TipoPokemon.poison: 2.0,
      TipoPokemon.rock: 2.0,
      TipoPokemon.steel: 2.0,
      TipoPokemon.bug: 0.5,
      TipoPokemon.grass: 0.5,
      TipoPokemon.flying: 0.0,
    },
    TipoPokemon.dragon: {
      TipoPokemon.dragon: 2.0,
      TipoPokemon.steel: 0.5,
      TipoPokemon.fairy: 0.0,
    },
    TipoPokemon.ghost: {
      TipoPokemon.ghost: 2.0,
      TipoPokemon.psychic: 2.0,
      TipoPokemon.dark: 0.5,
      TipoPokemon.normal: 0.0,
    },
    TipoPokemon.bug: {
      TipoPokemon.grass: 2.0,
      TipoPokemon.psychic: 2.0,
      TipoPokemon.dark: 2.0,
      TipoPokemon.fighting: 0.5,
      TipoPokemon.flying: 0.5,
      TipoPokemon.poison: 0.5,
      TipoPokemon.ghost: 0.5,
      TipoPokemon.steel: 0.5,
      TipoPokemon.fire: 0.5,
      TipoPokemon.fairy: 0.5,
    },
    TipoPokemon.fairy: {
      TipoPokemon.fighting: 2.0,
      TipoPokemon.dragon: 2.0,
      TipoPokemon.dark: 2.0,
      TipoPokemon.poison: 0.5,
      TipoPokemon.steel: 0.5,
      TipoPokemon.fire: 0.5,
    },
    TipoPokemon.psychic: {
      TipoPokemon.fighting: 2.0,
      TipoPokemon.poison: 2.0,
      TipoPokemon.steel: 0.5,
      TipoPokemon.psychic: 0.5,
      TipoPokemon.dark: 0.0,
    },
    TipoPokemon.poison: {
      TipoPokemon.grass: 2.0,
      TipoPokemon.fairy: 2.0,
      TipoPokemon.poison: 0.5,
      TipoPokemon.ground: 0.5,
      TipoPokemon.rock: 0.5,
      TipoPokemon.ghost: 0.5,
      TipoPokemon.steel: 0.0,
    },
    TipoPokemon.dark: {
      TipoPokemon.psychic: 2.0,
      TipoPokemon.ghost: 2.0,
      TipoPokemon.fighting: 0.5,
      TipoPokemon.dark: 0.5,
      TipoPokemon.fairy: 0.5,
    },
    TipoPokemon.steel: {
      TipoPokemon.ice: 2.0,
      TipoPokemon.rock: 2.0,
      TipoPokemon.fairy: 2.0,
      TipoPokemon.fire: 0.5,
      TipoPokemon.water: 0.5,
      TipoPokemon.electric: 0.5,
      TipoPokemon.steel: 0.5,
    },
    TipoPokemon.flying: {
      TipoPokemon.fighting: 2.0,
      TipoPokemon.bug: 2.0,
      TipoPokemon.grass: 2.0,
      TipoPokemon.rock: 0.5,
      TipoPokemon.steel: 0.5,
      TipoPokemon.electric: 0.5,
    },
    TipoPokemon.rock: {
      TipoPokemon.fire: 2.0,
      TipoPokemon.ice: 2.0,
      TipoPokemon.flying: 2.0,
      TipoPokemon.bug: 2.0,
      TipoPokemon.fighting: 0.5,
      TipoPokemon.ground: 0.5,
      TipoPokemon.steel: 0.5,
    },
  };

  @override
  double efectividad(TipoPokemon tipoAtaque, TipoPokemon tipoDefensa) {
    final fila = _tabla[tipoAtaque];
    return fila?[tipoDefensa] ?? 1.0; 
  }
}