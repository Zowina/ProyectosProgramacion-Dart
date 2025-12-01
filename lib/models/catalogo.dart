import 'package:batallas_pokemon/models/base.dart';
import 'dart:math';

List<Pokemon> crearCatalogoPokemon() {
    String _img(String name) => 'assets/img/${name.toLowerCase()}.png';

    final Movimiento placaje = Movimiento(nombre: 'Placaje', tipo: TipoPokemon.normal, poder: 40, precision: 0.95, ppMaximo: 35);
    final Movimiento patadaBaja = Movimiento(nombre: 'Patada Baja', tipo: TipoPokemon.fighting, poder: 60, precision: 0.9, ppMaximo: 25);
    final Movimiento golpeAereo = Movimiento(nombre: 'Golpe Aereo', tipo: TipoPokemon.flying, poder: 70, precision: 1.0, ppMaximo: 20);
    final Movimiento confusion = Movimiento(nombre: 'Confusion', tipo: TipoPokemon.psychic, poder: 50, precision: 1.0, ppMaximo: 25);
    final Movimiento picotazo = Movimiento(nombre: 'Picotazo', tipo: TipoPokemon.bug, poder: 35, precision: 1.0, ppMaximo: 35);

    final Movimiento ascuas = Movimiento(nombre: 'Ascuas', tipo: TipoPokemon.fire, poder: 40, precision: 0.95, estadoAInfigir: CondicionEstado.burned, probabilidadEstado: 0.1, ppMaximo: 25);
    final Movimiento llamarada = Movimiento(nombre: 'Llamarada', tipo: TipoPokemon.fire, poder: 110, precision: 0.7, estadoAInfigir: CondicionEstado.burned, probabilidadEstado: 0.2, ppMaximo: 5);
    final Movimiento punioFuego = Movimiento(nombre: 'Puno Fuego', tipo: TipoPokemon.fire, poder: 75, precision: 0.9, estadoAInfigir: CondicionEstado.burned, probabilidadEstado: 0.1, ppMaximo: 15);
    
    final Movimiento pistolaAgua = Movimiento(nombre: 'Pistola Agua', tipo: TipoPokemon.water, poder: 40, precision: 0.95, ppMaximo: 25);
    final Movimiento hidrobomba = Movimiento(nombre: 'Hidrobomba', tipo: TipoPokemon.water, poder: 110, precision: 0.7, ppMaximo: 5);
    final Movimiento surf = Movimiento(nombre: 'Surf', tipo: TipoPokemon.water, poder: 90, precision: 1.0, ppMaximo: 15);

    final Movimiento hojaAfilada = Movimiento(nombre: 'Hoja Afilada', tipo: TipoPokemon.grass, poder: 55, precision: 0.95, ppMaximo: 25);
    final Movimiento latigoCepa = Movimiento(nombre: 'Latigo Cepa', tipo: TipoPokemon.grass, poder: 45, precision: 1.0, ppMaximo: 25);
    final Movimiento rayoSolar = Movimiento(nombre: 'Rayo Solar', tipo: TipoPokemon.grass, poder: 120, precision: 1.0, ppMaximo: 10);
    
    final Movimiento impactrueno = Movimiento(nombre: 'Impactrueno', tipo: TipoPokemon.electric, poder: 40, precision: 0.95, estadoAInfigir: CondicionEstado.paralyzed, probabilidadEstado: 0.25, ppMaximo: 20);
    final Movimiento rayo = Movimiento(nombre: 'Rayo', tipo: TipoPokemon.electric, poder: 90, precision: 1.0, estadoAInfigir: CondicionEstado.paralyzed, probabilidadEstado: 0.1, ppMaximo: 15);
    final Movimiento chispazo = Movimiento(nombre: 'Chispazo', tipo: TipoPokemon.electric, poder: 80, precision: 1.0, ppMaximo: 15);
    
    final Movimiento rayoHielo = Movimiento(nombre: 'Rayo Hielo', tipo: TipoPokemon.ice, poder: 90, precision: 1.0, estadoAInfigir: CondicionEstado.frozen, probabilidadEstado: 0.1, ppMaximo: 10);
    final Movimiento ventisca = Movimiento(nombre: 'Ventisca', tipo: TipoPokemon.ice, poder: 110, precision: 0.7, estadoAInfigir: CondicionEstado.frozen, probabilidadEstado: 0.2, ppMaximo: 5);
    final Movimiento cantoHelado = Movimiento(nombre: 'Canto Helado', tipo: TipoPokemon.ice, poder: 65, precision: 1.0, ppMaximo: 20);

    final Movimiento golpeBajo = Movimiento(nombre: 'Golpe Bajo', tipo: TipoPokemon.fighting, poder: 75, precision: 1.0, ppMaximo: 15);
    final Movimiento doblePatada = Movimiento(nombre: 'Doble Patada', tipo: TipoPokemon.fighting, poder: 30, precision: 1.0, ppMaximo: 30);
    final Movimiento sumision = Movimiento(nombre: 'Sumision', tipo: TipoPokemon.fighting, poder: 85, precision: 0.85, ppMaximo: 20);
    
    final Movimiento terremoto = Movimiento(nombre: 'Terremoto', tipo: TipoPokemon.ground, poder: 100, precision: 1.0, ppMaximo: 10);
    final Movimiento excavar = Movimiento(nombre: 'Excavar', tipo: TipoPokemon.ground, poder: 80, precision: 1.0, ppMaximo: 10);
    final Movimiento disparoLodo = Movimiento(nombre: 'Disparo Lodo', tipo: TipoPokemon.ground, poder: 55, precision: 0.95, ppMaximo: 15);
    
    final Movimiento dragoAliento = Movimiento(nombre: 'Drago Aliento', tipo: TipoPokemon.dragon, poder: 60, precision: 1.0, ppMaximo: 20);
    final Movimiento cometaDraco = Movimiento(nombre: 'Cometa Draco', tipo: TipoPokemon.dragon, poder: 130, precision: 0.9, ppMaximo: 5);
    final Movimiento garraDragon = Movimiento(nombre: 'Garra Dragon', tipo: TipoPokemon.dragon, poder: 80, precision: 1.0, ppMaximo: 15);

    final Movimiento bolaSombra = Movimiento(nombre: 'Bola Sombra', tipo: TipoPokemon.ghost, poder: 80, precision: 1.0, ppMaximo: 15);
    final Movimiento lenguaLazuda = Movimiento(nombre: 'Lenguetazo', tipo: TipoPokemon.ghost, poder: 30, precision: 1.0, ppMaximo: 30);
    final Movimiento infortunio = Movimiento(nombre: 'Infortunio', tipo: TipoPokemon.ghost, poder: 65, precision: 1.0, ppMaximo: 10);
    
    final Movimiento tijeraX = Movimiento(nombre: 'Tijera X', tipo: TipoPokemon.bug, poder: 80, precision: 1.0, ppMaximo: 15);
    final Movimiento megacuerno = Movimiento(nombre: 'Megacuerno', tipo: TipoPokemon.bug, poder: 120, precision: 0.85, ppMaximo: 10);
    
    final Movimiento fuerzaLunar = Movimiento(nombre: 'Fuerza Lunar', tipo: TipoPokemon.fairy, poder: 95, precision: 1.0, ppMaximo: 15);
    final Movimiento carantoina = Movimiento(nombre: 'Carantoina', tipo: TipoPokemon.fairy, poder: 90, precision: 0.9, ppMaximo: 10);
    
    final Movimiento psiquico = Movimiento(nombre: 'Psiquico', tipo: TipoPokemon.psychic, poder: 90, precision: 1.0, ppMaximo: 10);
    
    final Movimiento gasVeneno = Movimiento(nombre: 'Gas Veneno', tipo: TipoPokemon.poison, poder: 0, precision: 0.9, estadoAInfigir: CondicionEstado.poisoned, probabilidadEstado: 1.0, ppMaximo: 40);
    final Movimiento bombaLodo = Movimiento(nombre: 'Bomba Lodo', tipo: TipoPokemon.poison, poder: 90, precision: 1.0, estadoAInfigir: CondicionEstado.poisoned, probabilidadEstado: 0.3, ppMaximo: 10);
    
    final Movimiento pulsoSombra = Movimiento(nombre: 'Pulso Sombra', tipo: TipoPokemon.dark, poder: 80, precision: 1.0, ppMaximo: 15);
    
    final Movimiento cabezaHierro = Movimiento(nombre: 'Cabeza Hierro', tipo: TipoPokemon.steel, poder: 80, precision: 1.0, ppMaximo: 15);

    final Movimiento tajoAereo = Movimiento(nombre: 'Tajo Aereo', tipo: TipoPokemon.flying, poder: 75, precision: 0.95, ppMaximo: 20);
    final Movimiento picoTaladro = Movimiento(nombre: 'Pico Taladro', tipo: TipoPokemon.flying, poder: 80, precision: 1.0, ppMaximo: 20);

    final Movimiento avalancha = Movimiento(nombre: 'Avalancha', tipo: TipoPokemon.rock, poder: 75, precision: 0.9, ppMaximo: 10);
    final Movimiento tumbaRocas = Movimiento(nombre: 'Tumba Rocas', tipo: TipoPokemon.rock, poder: 60, precision: 0.9, ppMaximo: 15);
    
    

    return [
      Pokemon(nombre: 'Charmander', tipo: TipoPokemon.fire, vidaMaxima: 100, velocidad: 65, rutaImagen: _img('charmander'), movimientos: [ascuas, punioFuego, placaje, patadaBaja]),
      Pokemon(nombre: 'Vulpix', tipo: TipoPokemon.fire, vidaMaxima: 110, velocidad: 80, rutaImagen: _img('vulpix'), movimientos: [llamarada, ascuas, patadaBaja, golpeAereo]),
      Pokemon(nombre: 'Growlithe', tipo: TipoPokemon.fire, vidaMaxima: 120, velocidad: 70, rutaImagen: _img('growlithe'), movimientos: [punioFuego, llamarada, placaje, golpeAereo]),
      
      Pokemon(nombre: 'Squirtle', tipo: TipoPokemon.water, vidaMaxima: 105, velocidad: 43, rutaImagen: _img('squirtle'), movimientos: [pistolaAgua, surf, placaje, patadaBaja]),
      Pokemon(nombre: 'Poliwag', tipo: TipoPokemon.water, vidaMaxima: 115, velocidad: 90, rutaImagen: _img('poliwag'), movimientos: [hidrobomba, pistolaAgua, golpeAereo, patadaBaja]),
      Pokemon(nombre: 'Staryu', tipo: TipoPokemon.water, vidaMaxima: 90, velocidad: 115, rutaImagen: _img('staryu'), movimientos: [surf, hidrobomba, placaje, golpeAereo]),

      Pokemon(nombre: 'Bulbasaur', tipo: TipoPokemon.grass, vidaMaxima: 110, velocidad: 45, rutaImagen: _img('bulbasaur'), movimientos: [hojaAfilada, latigoCepa, rayoSolar, placaje]),
      Pokemon(nombre: 'Oddish', tipo: TipoPokemon.grass, vidaMaxima: 125, velocidad: 30, rutaImagen: _img('oddish'), movimientos: [rayoSolar, latigoCepa, placaje, patadaBaja]),
      Pokemon(nombre: 'Bellsprout', tipo: TipoPokemon.grass, vidaMaxima: 95, velocidad: 70, rutaImagen: _img('bellsprout'), movimientos: [hojaAfilada, latigoCepa, golpeAereo, placaje]),

      Pokemon(nombre: 'Pikachu', tipo: TipoPokemon.electric, vidaMaxima: 90, velocidad: 100, rutaImagen: _img('pikachu'), movimientos: [impactrueno, rayo, placaje, chispazo]),
      Pokemon(nombre: 'Voltorb', tipo: TipoPokemon.electric, vidaMaxima: 100, velocidad: 100, rutaImagen: _img('voltorb'), movimientos: [chispazo, rayo, impactrueno, golpeAereo]),
      Pokemon(nombre: 'Magnemite', tipo: TipoPokemon.electric, vidaMaxima: 110, velocidad: 45, rutaImagen: _img('magnemite'), movimientos: [rayo, chispazo, impactrueno, patadaBaja]),
      
      Pokemon(nombre: 'Lapras', tipo: TipoPokemon.ice, vidaMaxima: 140, velocidad: 60, rutaImagen: _img('lapras'), movimientos: [rayoHielo, ventisca, surf, cantoHelado]),
      Pokemon(nombre: 'Jynx', tipo: TipoPokemon.ice, vidaMaxima: 100, velocidad: 95, rutaImagen: _img('jynx'), movimientos: [ventisca, rayoHielo, golpeAereo, confusion]),
      Pokemon(nombre: 'Dewgong', tipo: TipoPokemon.ice, vidaMaxima: 115, velocidad: 70, rutaImagen: _img('dewgong'), movimientos: [cantoHelado, rayoHielo, pistolaAgua, placaje]),

      Pokemon(nombre: 'Machop', tipo: TipoPokemon.fighting, vidaMaxima: 130, velocidad: 35, rutaImagen: _img('machop'), movimientos: [golpeBajo, doblePatada, sumision, placaje]),
      Pokemon(nombre: 'Hitmonlee', tipo: TipoPokemon.fighting, vidaMaxima: 100, velocidad: 87, rutaImagen: _img('hitmonlee'), movimientos: [doblePatada, sumision, patadaBaja, golpeBajo]),
      Pokemon(nombre: 'Pangoro', tipo: TipoPokemon.fighting, vidaMaxima: 150, velocidad: 58, rutaImagen: _img('pangoro'), movimientos: [sumision, golpeBajo, patadaBaja, placaje]),

      Pokemon(nombre: 'Diglett', tipo: TipoPokemon.ground, vidaMaxima: 80, velocidad: 95, rutaImagen: _img('diglett'), movimientos: [terremoto, excavar, disparoLodo, placaje]),
      Pokemon(nombre: 'Geodude', tipo: TipoPokemon.ground, vidaMaxima: 110, velocidad: 20, rutaImagen: _img('geodude'), movimientos: [disparoLodo, terremoto, patadaBaja, placaje]),
      Pokemon(nombre: 'Cubone', tipo: TipoPokemon.ground, vidaMaxima: 120, velocidad: 50, rutaImagen: _img('cubone'), movimientos: [excavar, terremoto, disparoLodo, patadaBaja]),

      Pokemon(nombre: 'Dratini', tipo: TipoPokemon.dragon, vidaMaxima: 90, velocidad: 50, rutaImagen: _img('dratini'), movimientos: [dragoAliento, garraDragon, placaje, hidrobomba]),
      Pokemon(nombre: 'Dragonair', tipo: TipoPokemon.dragon, vidaMaxima: 110, velocidad: 70, rutaImagen: _img('dragonair'), movimientos: [dragoAliento, cometaDraco, garraDragon, golpeAereo]),
      Pokemon(nombre: 'Gible', tipo: TipoPokemon.dragon, vidaMaxima: 120, velocidad: 42, rutaImagen: _img('gible'), movimientos: [garraDragon, terremoto, dragoAliento, placaje]),

      Pokemon(nombre: 'Gastly', tipo: TipoPokemon.ghost, vidaMaxima: 80, velocidad: 80, rutaImagen: _img('gastly'), movimientos: [bolaSombra, lenguaLazuda, infortunio, gasVeneno]),
      Pokemon(nombre: 'Misdreavus', tipo: TipoPokemon.ghost, vidaMaxima: 95, velocidad: 85, rutaImagen: _img('misdreavus'), movimientos: [bolaSombra, confusion, infortunio, psiquico]),
      Pokemon(nombre: 'Haunter', tipo: TipoPokemon.ghost, vidaMaxima: 100, velocidad: 95, rutaImagen: _img('haunter'), movimientos: [bolaSombra, gasVeneno, infortunio, lenguaLazuda]),
      
      Pokemon(nombre: 'Caterpie', tipo: TipoPokemon.bug, vidaMaxima: 90, velocidad: 45, rutaImagen: _img('caterpie'), movimientos: [picotazo, placaje, tijeraX, hojaAfilada]),
      Pokemon(nombre: 'Scyther', tipo: TipoPokemon.bug, vidaMaxima: 110, velocidad: 115, rutaImagen: _img('scyther'), movimientos: [tijeraX, golpeAereo, doblePatada, megacuerno]),
      Pokemon(nombre: 'Pinsir', tipo: TipoPokemon.bug, vidaMaxima: 130, velocidad: 85, rutaImagen: _img('pinsir'), movimientos: [megacuerno, tijeraX, sumision, placaje]),
      
      Pokemon(nombre: 'Clefairy', tipo: TipoPokemon.fairy, vidaMaxima: 130, velocidad: 35, rutaImagen: _img('clefairy'), movimientos: [fuerzaLunar, carantoina, golpeBajo, placaje]),
      Pokemon(nombre: 'Jigglypuff', tipo: TipoPokemon.fairy, vidaMaxima: 150, velocidad: 20, rutaImagen: _img('jigglypuff'), movimientos: [carantoina, fuerzaLunar, placaje, golpeBajo]),
      Pokemon(nombre: 'Togepi', tipo: TipoPokemon.fairy, vidaMaxima: 90, velocidad: 20, rutaImagen: _img('togepi'), movimientos: [fuerzaLunar, carantoina, confusion, placaje]),

      Pokemon(nombre: 'Abra', tipo: TipoPokemon.psychic, vidaMaxima: 80, velocidad: 90, rutaImagen: _img('abra'), movimientos: [psiquico, confusion, golpeBajo, placaje]),
      Pokemon(nombre: 'Mewtwo', tipo: TipoPokemon.psychic, vidaMaxima: 150, velocidad: 130, rutaImagen: _img('mewtwo'), movimientos: [psiquico, confusion, golpeAereo, rayo]),
      Pokemon(nombre: 'Alakazam', tipo: TipoPokemon.psychic, vidaMaxima: 110, velocidad: 120, rutaImagen: _img('alakazam'), movimientos: [psiquico, confusion, rayoHielo, golpeBajo]),

      Pokemon(nombre: 'Ekans', tipo: TipoPokemon.poison, vidaMaxima: 100, velocidad: 55, rutaImagen: _img('ekans'), movimientos: [bombaLodo, gasVeneno, placaje, patadaBaja]),
      Pokemon(nombre: 'Koffing', tipo: TipoPokemon.poison, vidaMaxima: 110, velocidad: 35, rutaImagen: _img('koffing'), movimientos: [gasVeneno, bombaLodo, placaje, llamarada]),
      Pokemon(nombre: 'Grimer', tipo: TipoPokemon.poison, vidaMaxima: 140, velocidad: 25, rutaImagen: _img('grimer'), movimientos: [bombaLodo, gasVeneno, sumision, placaje]),

      Pokemon(nombre: 'Murkrow', tipo: TipoPokemon.dark, vidaMaxima: 90, velocidad: 91, rutaImagen: _img('murkrow'), movimientos: [pulsoSombra, golpeAereo, placaje, confusion]),
      Pokemon(nombre: 'Sneasel', tipo: TipoPokemon.dark, vidaMaxima: 100, velocidad: 115, rutaImagen: _img('sneasel'), movimientos: [pulsoSombra, golpeBajo, cantoHelado, doblePatada]),
      Pokemon(nombre: 'Poochyena', tipo: TipoPokemon.dark, vidaMaxima: 110, velocidad: 35, rutaImagen: _img('poochyena'), movimientos: [pulsoSombra, placaje, patadaBaja, lenguaLazuda]),
      
      Pokemon(nombre: 'Aron', tipo: TipoPokemon.steel, vidaMaxima: 100, velocidad: 30, rutaImagen: _img('aron'), movimientos: [cabezaHierro, terremoto, placaje, patadaBaja]),
      Pokemon(nombre: 'Beldum', tipo: TipoPokemon.steel, vidaMaxima: 90, velocidad: 30, rutaImagen: _img('beldum'), movimientos: [cabezaHierro, psiquico, confusion, placaje]),
      Pokemon(nombre: 'Klink', tipo: TipoPokemon.steel, vidaMaxima: 110, velocidad: 50, rutaImagen: _img('klink'), movimientos: [cabezaHierro, chispazo, rayo, placaje]),

      Pokemon(nombre: 'Pidgey', tipo: TipoPokemon.flying, vidaMaxima: 90, velocidad: 60, rutaImagen: _img('pidgey'), movimientos: [golpeAereo, tajoAereo, picoTaladro, placaje]),
      Pokemon(nombre: 'Fearow', tipo: TipoPokemon.flying, vidaMaxima: 110, velocidad: 100, rutaImagen: _img('fearow'), movimientos: [picoTaladro, golpeAereo, tajoAereo, patadaBaja]),
      Pokemon(nombre: 'Swablu', tipo: TipoPokemon.flying, vidaMaxima: 100, velocidad: 50, rutaImagen: _img('swablu'), movimientos: [golpeAereo, tajoAereo, picotazo, confusion]),

      Pokemon(nombre: 'Onix', tipo: TipoPokemon.rock, vidaMaxima: 120, velocidad: 70, rutaImagen: _img('onix'), movimientos: [avalancha, tumbaRocas, terremoto, placaje]),
      Pokemon(nombre: 'Rhyhorn', tipo: TipoPokemon.rock, vidaMaxima: 130, velocidad: 25, rutaImagen: _img('rhyhorn'), movimientos: [tumbaRocas, avalancha, cabezaHierro, excavar]),
      Pokemon(nombre: 'Sudowoodo', tipo: TipoPokemon.rock, vidaMaxima: 110, velocidad: 30, rutaImagen: _img('sudowoodo'), movimientos: [avalancha, tumbaRocas, patadaBaja, placaje]),
    ];
}