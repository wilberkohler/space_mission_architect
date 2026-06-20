import 'package:flutter/material.dart';

class LocalizedIntroText {
  const LocalizedIntroText._();

  static String forLocale(Locale locale) {
    final String code = locale.languageCode.toLowerCase();
    switch (code) {
      case 'pt':
        return _pt;
      case 'es':
        return _es;
      default:
        return _en;
    }
  }

  static const String _pt =
      'Por décadas, nações e agências conquistaram o espaço com decisões difíceis, testes incertos e coragem técnica. Algumas missões mudaram a história — outras falharam, mas ensinaram.\n\n'
      'Agora é a sua vez. Gerencie recursos, equipe e risco. Teste, lance, aborte quando necessário. Avance até liderar missões que podem mudar tudo.\n\n'
      'A conquista do espaço começa com uma decisão.';

  static const String _en =
      'Curiosity became engineering. Risk became discovery. Ambition became exploration.\n\n'
      'For decades, nations and agencies pushed into space with hard choices, uncertain tests, and technical courage. Some missions changed history — others failed, but taught.\n\n'
      'Now it is your turn. Manage resources, crew, and risk. Test, launch, abort when needed. Rise to lead missions that can change everything.\n\n'
      'The conquest of space starts with a decision.';

  static const String _es =
      'Desde los primeros suenos de alcanzar el cielo, la humanidad transformo la curiosidad en ingenieria, el riesgo en descubrimiento y la ambicion en exploracion.\n\n'
      'Desde los primeros cohetes experimentales hasta los satelites artificiales, desde las capsulas tripuladas hasta las estaciones orbitales, desde las sondas planetarias hasta las misiones rumbo a la Luna, Marte, Venus, Mercurio y el Sol, cada avance exigio decisiones dificiles, pruebas inciertas, presupuestos limitados y valentia tecnica.\n\n'
      'A lo largo de las decadas, miles de lanzamientos y misiones espaciales fueron realizados por diferentes naciones, agencias y equipos. Algunas misiones cambiaron la historia. Otras fallaron, pero dejaron lecciones fundamentales.\n\n'
      'Ahora comienzas tu propia trayectoria dentro de un programa espacial. Empezaras con responsabilidades pequenas, aprenderas con pruebas, errores y exitos, y podras avanzar hasta liderar grandes misiones historicas.\n\n'
      'Gestiona recursos, reputacion, equipo, tecnologia y riesgo. Prueba cuando sea necesario. Lanza cuando estes listo. Aborta cuando sea prudente. Y, en situaciones extremas, toma decisiones criticas para evitar desastres mayores.\n\n'
      'La conquista del espacio comienza con una decision.';
}
