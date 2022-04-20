
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:game_project/pages/games_mode/game_mode_000/game_mode_000.dart';
import 'package:game_project/pages/games_mode/game_mode_001/functions/functions.dart';
import 'package:game_project/pages/start_menu.dart';
import 'package:responsive_grid/responsive_grid.dart';

import '../games_mode/game_mode_001/game_mode_001.dart';
import 'constants.dart';

///ESCOLHA O TIPO DE JOGO
message_choose_game_type(context){
  return AwesomeDialog(
    width: 600,
    dismissOnBackKeyPress: false,
    dismissOnTouchOutside: false,
    context: context,
    dialogType: DialogType.QUESTION,
    animType: AnimType.SCALE,
    body: Container(
        constraints: BoxConstraints(maxWidth: 500),
        child: Padding(
          padding: EdgeInsets.only(right: 0),
          child: Column(
            children: <Widget>[
              Text(
                "Escolha um modo de jogo",
                style: TextStyle(
                    fontSize: 15,
                    color: Colors.black,
                    fontWeight:
                    FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: 15,
              ),
              Column(
                children: [
                  Text(
                    "Modo Tradicional: ",
                    style: TextStyle(
                        fontSize: 13,
                        color: Colors.black,
                        fontWeight:
                        FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Text(
                    "Nesse modo de jogo, o jogador terá 30 bolinhas por rodada, "
                        "para cada rodada o jogador terá que sortear o máximo de bolinhas, "
                        "até conseguir 3 da mesma cor para vencer.",
                    style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        fontWeight:
                        FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Container(
                    constraints: BoxConstraints(maxWidth: 300),
                    child: InkWell(
                      onTap: () async {

                        Map <String, dynamic> room_config = {};

                        room_config['game_mode'] = 0;

                        //SALVANDO MODO DE JOGO TRADICIONAL
                        await FirebaseFirestore.instance.collection('rooms')
                            .doc(user_local['room']).update(room_config);

                        //MUDANDANDO PARA A PAGINA DA SALA DO JOGO
                        change_screen(context, GamePageMode000());

                      },
                      child: Container(
                        decoration: BoxDecoration(color: Colors.blue,
                            borderRadius: BorderRadius.circular(20)),
                        alignment: Alignment.center,
                        width: double.maxFinite,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Text("Jogar Tradicional", style: TextStyle(color: Colors.white),),
                      ),
                    ),
                  )
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Column(
                children: [
                  Text(
                    "Modo Soma de Bolinhas: ",
                    style: TextStyle(
                        fontSize: 13,
                        color: Colors.black,
                        fontWeight:
                        FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Text(
                    "No modo Soma de Bolinhas o jogador começará com 3 bolinhas no inicio da partida, "
                        "para cada rodada o número de bolinhas para retirar será aumentado uma bolinha a mais, "
                        "o jogador que conseguir 3 bolinhas da mesma cor em uma rodada vence.",
                    style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        fontWeight:
                        FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Container(
                    constraints: BoxConstraints(maxWidth: 300),
                    child: InkWell(
                      onTap: () async {

                        Map <String, dynamic> room_config = {};

                        room_config['game_mode'] = 1;

                        //SALVANDO MODO DE JOGO SOMA DE BOLINHAS
                        await FirebaseFirestore.instance.collection('rooms')
                            .doc(user_local['room']).update(room_config);

                        //MUDANDANDO PARA A PAGINA DA SALA DO JOGO
                        change_screen(context, GamePageMode001());

                      },
                      child: Container(
                        decoration: BoxDecoration(color: Colors.blue,
                            borderRadius: BorderRadius.circular(20)),
                        alignment: Alignment.center,
                        width: double.maxFinite,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Text("Jogar Soma de Bolinhas", style: TextStyle(color: Colors.white, fontSize: 13),),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                ],
              ),
            ],
          ),
        )
    ),
  )..show();
}


///CONFIG ROOM MODAL
modal_config_room(context){
  return AwesomeDialog(
    width: 600,
    context: context,
    dialogType: DialogType.NO_HEADER,
    body: Container(
        constraints: BoxConstraints(maxWidth: 500),
        child: Padding(
          padding: EdgeInsets.only(right: 0),
          child: Column(
            children: <Widget>[
              Text(
                "CONFIGURAÇÕES DA SALA",
                style: TextStyle(
                    fontSize: 15,
                    color: Colors.black,
                    fontWeight:
                    FontWeight.bold),
                  textAlign: TextAlign.center,
              ),
              SizedBox(
                height: 15,
              ),
              Padding(padding: EdgeInsets.only(bottom: 10),
                child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('rooms')
                        .doc(user_local['room'])
                        .collection('participants')
                        .snapshots(),
                    builder: (context, _participants_data) {
                      if (!_participants_data.hasData)
                        return Container();
                      else
                        return Container(
                          constraints:
                          BoxConstraints(maxWidth: 500),
                          child: Column(
                            children: [
                              Column(
                                children: [
                                  Material(
                                      elevation: 3,
                                      borderRadius: BorderRadius.circular(5),
                                      shadowColor: Colors.black,
                                      child: Column(
                                        children: [
                                          Align(
                                            child: Padding(
                                              padding:
                                              EdgeInsets.only(
                                                  top: 10, left: 5),
                                              child: Text(
                                                'JOGADORES NA PARTIDA:',
                                                style: TextStyle(
                                                    fontSize: 14.5,
                                                    color: Colors
                                                        .grey),
                                                textAlign: TextAlign.left,
                                              ),
                                            ),
                                            alignment: Alignment.topLeft,
                                          ),
                                          Column(
                                            children: List.generate(
                                                _participants_data
                                                    .data
                                                    .docs
                                                    .length,
                                                    (index) {
                                                  return Padding(
                                                      padding:
                                                      EdgeInsets
                                                          .all(2),
                                                      child: Column(
                                                        children: [
                                                          Row(
                                                            mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                            children: [
                                                              Row(
                                                                children: [
                                                                  Icon(
                                                                    Icons.account_circle,
                                                                    color: Colors.grey,
                                                                  ),
                                                                  SizedBox(
                                                                    width: 5,
                                                                  ),
                                                                  Text(
                                                                    '${_participants_data.data.docs[index].id == user_local['id'] ? '${_participants_data.data.docs[index].data()['user_name']} (Você)' : _participants_data.data.docs[index].data()['user_name']}',
                                                                    style: TextStyle(fontSize: 13, color: Colors.grey),
                                                                  )
                                                                ],
                                                              ),
                                                              _participants_data.data.docs[index].data()['host'] == true ?
                                                              Container() :
                                                              IconButton(onPressed: () async {
                                                                await quit_player(context, 'player', false, _participants_data.data.docs[index].id);
                                                              }, icon: Icon(Icons.close, color: Colors.red, size: 17,))
                                                            ],
                                                          )
                                                        ],
                                                      ));
                                                }),
                                          ),
                                        ],
                                      )),
                                ],
                              ),
                            ],
                          ),
                        );
                    }),
              )
            ],
          ),
        )
    ),
    btnOkText: 'Fechar',
    btnOkOnPress: (){},
    btnOkColor: Colors.blue
  )..show();
}


///Você tirou 3 números de cores iguais.(PARTICIPANT)
///Aguarde até que o Host reinicie a partida para jogar novamente !
message_very_luck_participant(context){
  return AwesomeDialog(
    width: 600,
    dismissOnBackKeyPress: false,
    dismissOnTouchOutside: false,
    context: context,
    dialogType: DialogType.SUCCES,
    animType: AnimType.SCALE,
    body: Container(
        constraints: BoxConstraints(maxWidth: 500),
        child: Padding(
          padding: EdgeInsets.only(right: 0),
          child: Column(
            children: <Widget>[
              Text(
                "PARABÉNS!!",
                style: TextStyle(
                    fontSize: 15,
                    color: Colors.green,
                    fontWeight:
                    FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              Text(
                'VOCÊ ACABA DE GANHAR A PARTIDA COM 3 BOLINHAS DA MESMA COR!!',
                style: TextStyle(
                    fontSize: 15,
                    color: Colors.green,
                    fontWeight:
                    FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: 5,
              ),
              StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore
                      .instance.collection('rooms')
                      .doc(user_local['room']).collection('participants').doc(user_local['id'])
                      .collection('numbers').orderBy('number', descending: false)
                      .snapshots(),
                  builder: (context, numbers) {
                    if (numbers.data == null) return Container();
                    return ResponsiveGridList(
                      desiredItemWidth: 50,
                      minSpacing: 5,
                      scroll: false,
                      children: List.generate(
                        numbers.data.docs.length,
                            (index) =>
                            RawMaterialButton(
                              constraints: BoxConstraints
                                  .expand(
                                  width: 45, height: 50),

                              onPressed: () {},
                              elevation: 2.0,
                              fillColor: numbers.data.docs[index]
                                  .data()['color'] ==
                                  'red'
                                  ?
                              Colors.red
                                  : numbers.data.docs[index]
                                  .data()['color'] ==
                                  'green' ?
                              Colors.green : Colors.blue
                              ,
                              child: Text(
                                '${numbers.data.docs[index]
                                    .data()['number']}',
                                style: TextStyle(fontSize: 13,
                                    color: Colors.white),),
                              shape: CircleBorder(),
                            ),
                      ),
                    );
                  }),

            ],
          ),
        )
    ),
    btnCancelOnPress: () async {

      //SAINDO DA PARTIDA
      await quit_player(context, 'player', true, null);

      //MUDANDANDO PARA A PAGINA INICIAL
      change_screen(context, StartGame());
    },
    btnOkOnPress: () async {
    },
    btnOkText: 'Aguardar',
    btnCancelText: 'Sair da partida',

    btnOkColor: Colors.blue,
  )..show();
}

///Você tirou 3 números de cores iguais.(HOST)
message_very_luck_host(context){
  return AwesomeDialog(
    width: 600,
    dismissOnBackKeyPress: false,
    dismissOnTouchOutside: false,
    context: context,
    dialogType: DialogType.SUCCES,
    animType: AnimType.SCALE,
    body: Center(
        child: Container(
            constraints: BoxConstraints(maxWidth: 500),
            child: Padding(
              padding: EdgeInsets.only(right: 0),
              child: Column(
                children: <Widget>[
                  Text(
                    "PARABÉNS!!",
                    style: TextStyle(
                        fontSize: 15,
                        color: Colors.green,
                        fontWeight:
                        FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    'VOCÊ ACABA DE GANHAR A PARTIDA COM 3 BOLINHAS DA MESMA COR!!',
                    style: TextStyle(
                        fontSize: 15,
                        color: Colors.green,
                        fontWeight:
                        FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore
                          .instance.collection('rooms')
                          .doc(user_local['room']).collection('participants').doc(user_local['id'])
                          .collection('numbers').orderBy('number', descending: false)
                          .snapshots(),
                      builder: (context, numbers) {
                        if (numbers.data == null) return Container();
                        return ResponsiveGridList(
                          desiredItemWidth: 50,
                          minSpacing: 5,
                          scroll: false,
                          children: List.generate(
                            numbers.data.docs.length,
                                (index) =>
                                RawMaterialButton(
                                  constraints: BoxConstraints
                                      .expand(
                                      width: 45, height: 50),

                                  onPressed: () {},
                                  elevation: 2.0,
                                  fillColor: numbers.data.docs[index]
                                      .data()['color'] ==
                                      'red'
                                      ?
                                  Colors.red
                                      : numbers.data.docs[index]
                                      .data()['color'] ==
                                      'green' ?
                                  Colors.green : Colors.blue
                                  ,
                                  child: Text(
                                    '${numbers.data.docs[index]
                                        .data()['number']}',
                                    style: TextStyle(fontSize: 13,
                                        color: Colors.white),),
                                  shape: CircleBorder(),
                                ),
                          ),
                        );
                      }),
                ],
              ),
            )
        )),
    btnCancelOnPress: () async {
      await quit_player(context, 'host', true, null);
    },
    btnOkOnPress: () async {
    },
    btnOkText: 'Continuar',
    btnCancelText: 'Sair da partida',
    btnOkColor: Colors.blue,
  )..show();
}

///NOME VAZIO
message_name_empty(context){
  return AwesomeDialog(
    width: 500,
    dismissOnBackKeyPress: false,
    dismissOnTouchOutside: false,
    context: context,
    dialogType: DialogType.ERROR,
    animType: AnimType.SCALE,
    title: 'Ops...',
    desc: 'Preencha um nome antes de continuar.',
    btnOkOnPress: () async {
    },
    btnOkText: 'Ok',
    btnOkColor: Colors.blue,
  )..show();
}

///SALA NAO ENCONTRADA
message_room_not_found(context){
  return AwesomeDialog(
    width: 500,
    dismissOnBackKeyPress: false,
    dismissOnTouchOutside: false,
    context: context,
    dialogType: DialogType.ERROR,
    animType: AnimType.SCALE,
    title: 'Ops...',
    desc: 'Sala não encontrada.',
    btnOkOnPress: () async {
    },
    btnOkText: 'Voltar',
    btnOkColor: Colors.blue,
  )..show();
}

///AGUARDE TODOS OS JOGADORES
message_room_players_empty(context){
  return AwesomeDialog(
    width: 500,
    dismissOnBackKeyPress: false,
    dismissOnTouchOutside: false,
    context: context,
    dialogType: DialogType.INFO,
    animType: AnimType.SCALE,
    title: 'Ops...',
    desc: 'Aguarde até que todos os jogadores entrem',
    btnOkOnPress: () async {
    },
    btnOkText: 'Voltar',
    btnOkColor: Colors.blue,
  )..show();
}