import 'package:flutter/material.dart';

class Sobre extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Widget titleSection = Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            /*1*/
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /*2*/
                Container(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    'RGTI - Soluções em Tecnologia',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  'Software para sua empresa',
                  style: TextStyle(
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    //Color color = Theme.of(context).primaryColor;

    Widget textSection = Container(
      padding: const EdgeInsets.all(16),
      child: Text(
        'É uma empresa com foco em consultoria que atua em toda a área de '
        'Sistemas de Gestão ERP. Além do setor de consultoria, desenvolvemos '
        'softwares personalizados para auxiliar nos processos empresariais de '
        'nossos clientes.'
        'Uma empresa de política sólida e de ideias flexíveis procurando sempre '
        'atender às necessidades de seus clientes, com soluções e inovações em '
        'seus processos e negócios, sempre em busca de melhoria contínua.'
        'Contamos com um time de profissionais altamente qualificados nas áreas '
        'de Tecnologia da Informação, com especialização na área de Projetos e '
        'Gestão de Pessoas.',
        softWrap: true,
      ),
    );

    return Container(
      child: ListView(
        children: [
          Image.asset(
            'images/logorgti.jpg',
            width: 300,
            height: 300,
            fit: BoxFit.cover,
          ),
          titleSection,
          textSection,
        ],
      ),
    );
  }
}
