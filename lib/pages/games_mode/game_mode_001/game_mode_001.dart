import 'dart:math';
import 'dart:html' as html;
import 'package:animated_widgets/widgets/opacity_animated.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:responsive_grid/responsive_grid.dart';
import '../../helpers/constants.dart';
import 'functions/functions.dart';
import '../../helpers/messages.dart';

class GamePageMode001 extends StatefulWidget {
  @override
  GamePageMode001State createState() => GamePageMode001State();
}

class GamePageMode001State extends State<GamePageMode001> {

  bool button_lock = true;
  List numbers_sorted = [];
  List colors_sorted = [];

  //RESETANDO OS NUMEROS DO VENCEDOR
  reset_numbers_and_colors() {
    setState(() {
      numbers_sorted = [];
      colors_sorted = [];
    });
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        actions: [
          user_local['host'] == true ?
          IconButton(
            onPressed: () async {
              modal_config_room(context);
            },
            icon: Icon(Icons.settings),
            color: Colors.grey,
          ):
          Container(),
          SizedBox(width: 5,),
          IconButton(
            onPressed: () async {
              await quit_player(
                  context, user_local['host'] == true ? 'host' : 'player', true, null);
            },
            icon: Icon(Icons.exit_to_app),
            color: Colors.red,
          )
        ],
        title: Column(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Text(
                'Game',
                style: TextStyle(fontSize: 17, color: Colors.blue),
              ),
            ),
            Align(
              alignment: Alignment.topLeft,
              child: Text('Game / Room ${user_local['room']}',
                  style: TextStyle(fontSize: 13, color: Colors.grey)),
            )
          ],
        ),
        automaticallyImplyLeading: false,
      ),
      body: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('rooms')
              .doc(user_local['room'])
              .snapshots(),
          builder: (context, _room_data) {
            if (!_room_data.hasData)
              return Container();
            else
              html.window.onBeforeUnload.listen((event) async {
                if (event.type == 'beforeunload') {
                  quit_player(
                      context, user_local['host'] == true ? 'host' : 'player', true, null);
                }
              });
              return StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('rooms')
                      .doc(user_local['room'])
                      .collection('participants')
                      .snapshots(),
                builder: (context, _participants_data) {
                  if (!_participants_data.hasData)
                    return Container();
                  else
                    return StreamBuilder<DocumentSnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('rooms')
                            .doc(user_local['room'])
                            .collection('participants')
                            .doc(user_local['id'])
                            .snapshots(),
                        builder: (context, _participant_document) {
                          try{
                            if (!_participant_document.data.exists)
                              return Container(
                                padding: EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.stretch,
                                  mainAxisAlignment:
                                  MainAxisAlignment.center,
                                  children: <Widget>[
                                    Icon(
                                      Icons.warning_amber_outlined,
                                      size: 96.0,
                                      color: Colors.black,
                                    ),
                                    SizedBox(
                                      height: 16.0,
                                    ),
                                    Text(
                                      "Você foi expulso da sala... :)",
                                      style: TextStyle(
                                          fontSize: 22.0,
                                          color: Colors.black,
                                          fontWeight:
                                          FontWeight.bold),
                                      textAlign: TextAlign.center,
                                    ),
                                    SizedBox(
                                      height: 16.0,
                                    ),
                                  ],
                                ),
                              );
                            else

                              return Stack(
                                children: <Widget>[
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment
                                        .stretch,
                                    mainAxisAlignment: MainAxisAlignment
                                        .spaceBetween,
                                    children: [
                                      Expanded(
                                        child: ListView(
                                          children: [
                                            _room_data.data.data()[
                                            'user_winner'] ==
                                                null ?
                                            Padding(
                                              padding: EdgeInsets.only(
                                                  right: 5, left: 10, top: 10),
                                              child: InkWell(
                                                onTap: () async {
                                                  //VERIFICANDO SE TODOS OS JOGADORES ENTRARAM
                                                  if (_participants_data
                                                      .data.docs.length != 1) {
                                                    //VERIFICANDO SE E A VEZ DO JOGADOR
                                                    if (_room_data.data
                                                        .data()['name_playing'] ==
                                                        user_local['name'] &&
                                                        button_lock == true) {
                                                      setState(() {
                                                        button_lock = false;
                                                      });

                                                      try {
                                                        await reset_numbers_player();
                                                        reset_numbers_and_colors();
                                                      } catch (e) {}

                                                      on_sort_balls() async {
                                                        //GERANDO NOVOS NUMEROS ALEATORIAMENTE PARA O JOGADOR
                                                        Future<bool>
                                                        sorting_number() async {
                                                          final _random = Random();

                                                          //LISTA DE CORES
                                                          List red_colors = [];
                                                          List green_colors = [
                                                          ];
                                                          List blue_colors = [];

                                                          //LOOP COM NUMERO DE VOLTAS DEFINIDO PELA SALA
                                                          for (var n = 1;
                                                          n <
                                                              _room_data.data
                                                                  .data()[
                                                              'number_of_balls'];
                                                          n++) {
                                                            //SALVANDO OS NUMEROS EM UMA LISTA
                                                            var color = colors_sort[
                                                            _random.nextInt(
                                                                colors_sort
                                                                    .length)];

                                                            colors_sorted.add(
                                                                color);

                                                            //SALVANDO AS CORES NAS LISTAS
                                                            if (color ==
                                                                'red') {
                                                              red_colors.add(1);
                                                            } else if (color ==
                                                                'green') {
                                                              green_colors.add(
                                                                  1);
                                                            } else if (color ==
                                                                'blue') {
                                                              blue_colors.add(
                                                                  1);
                                                            }

                                                            //SALVANDO O NUMERO E A COR EM UM MAP PARA MOSTRAR NA TELA
                                                            setState(() {
                                                              Map _number = {};
                                                              _number['number'] =
                                                                  n;
                                                              _number['color'] =
                                                                  color;
                                                              numbers_sorted
                                                                  .add(
                                                                  _number);
                                                            });

                                                            //SALVANDO O RESULTADO DAS BOLINHAS ONLINE
                                                            Map<String, dynamic>
                                                            numbers_update_online =
                                                            {};
                                                            numbers_update_online[
                                                            'number'] = n;
                                                            numbers_update_online[
                                                            'color'] = color;

                                                            await FirebaseFirestore
                                                                .instance
                                                                .collection(
                                                                'rooms')
                                                                .doc(
                                                                user_local['room'])
                                                                .collection(
                                                                'participants')
                                                                .doc(
                                                                user_local['id'])
                                                                .collection(
                                                                'numbers')
                                                                .add(
                                                                numbers_update_online);

                                                            //DEFININDO O VENCEDOR CASO RETORNE 3 CORES IGUAIS DENTRO DA LISTA DAS CORES
                                                            if (red_colors
                                                                .length ==
                                                                3 ||
                                                                green_colors
                                                                    .length ==
                                                                    3 ||
                                                                blue_colors
                                                                    .length ==
                                                                    3) {
                                                              if (user_local['host'] ==
                                                                  true) {
                                                                message_very_luck_host(
                                                                    context);
                                                              } else {
                                                                message_very_luck_participant(
                                                                    context);
                                                              }

                                                              return true;
                                                            } else {}
                                                          }
                                                        }

                                                        Map<String,
                                                            dynamic>room_config_updates = {
                                                        };
                                                        update_room_state() async {
                                                          room_config_updates['rounds'] =
                                                          _room_data.data
                                                              .data()['rounds'] +=
                                                          1;

                                                          await FirebaseFirestore
                                                              .instance
                                                              .collection(
                                                              'rooms')
                                                              .doc(
                                                              user_local['room'])
                                                              .update(
                                                              room_config_updates);
                                                        }

                                                        Map<String,
                                                            dynamic>updates_player = {
                                                        };
                                                        update_player_state() async {
                                                          //BUSCANDO INFO DO JOGADOR
                                                          DocumentSnapshot player_data =
                                                          await FirebaseFirestore
                                                              .instance
                                                              .collection(
                                                              'rooms')
                                                              .doc(
                                                              user_local['room'])
                                                              .collection(
                                                              'participants')
                                                              .doc(
                                                              user_local['id'])
                                                              .get();

                                                          //SOMANDO UMA NOVA JOGADA E TIRANDO SUA PREFERNCIA DO JOGO
                                                          updates_player['plays'] =
                                                          player_data
                                                              .data()['plays'] +=
                                                          1;
                                                          updates_player['preference'] =
                                                          false;

                                                          //SALVANDO AS NOVAS CONFIG DO JOGADOR PARA NA SALA
                                                          await FirebaseFirestore
                                                              .instance
                                                              .collection(
                                                              'rooms')
                                                              .doc(
                                                              user_local['room'])
                                                              .collection(
                                                              'participants')
                                                              .doc(
                                                              user_local['id'])
                                                              .update(
                                                              updates_player);
                                                        }

                                                        //ESCOLENDO O PROXIMO JOGADOR
                                                        get_next_player() async {
                                                          //BUSCANDO NOVO JOGADOR COM MENOR NUMERO DE JOGADAS
                                                          QuerySnapshot all_players = await FirebaseFirestore
                                                              .instance
                                                              .collection(
                                                              'rooms')
                                                              .doc(
                                                              user_local['room'])
                                                              .collection(
                                                              'participants')
                                                              .where('plays',
                                                              isLessThan: updates_player['plays'])
                                                              .get();

                                                          Map<String,
                                                              dynamic> updates_next_player = {
                                                          };
                                                          room_config_updates =
                                                          {};

                                                          //SE NAO ACHAR PROXIMO JOGADOR A RODADA VOLTA PARA O HOST
                                                          if (all_players.docs
                                                              .length !=
                                                              0) {
                                                            //MUDANDO A PREFERENCIA PARA O JOGADOR
                                                            updates_next_player['preference'] =
                                                            true;

                                                            //SALVANDO QUEM JOGARA NA PROXIMA PARTIDA PARA AS CONFIG DA SALA
                                                            room_config_updates['name_playing'] =
                                                            all_players.docs[0]
                                                                .data()['user_name'];

                                                            //SALVANDO AS NOVAS CONFIG DO JOGADOR
                                                            await FirebaseFirestore
                                                                .instance
                                                                .collection(
                                                                'rooms')
                                                                .doc(
                                                                user_local['room'])
                                                                .collection(
                                                                'participants')
                                                                .doc(
                                                                all_players
                                                                    .docs[0].id)
                                                                .update(
                                                                updates_next_player);

                                                            //SALVANDO AS NOVAS CONFIG DA SALA
                                                            await FirebaseFirestore
                                                                .instance
                                                                .collection(
                                                                'rooms')
                                                                .doc(
                                                                user_local['room'])
                                                                .update(
                                                                room_config_updates);

                                                            //ADICIONANDO NOVO NUMERO BOLINHAS DIPONIVEL POR RODADA NA PARTIDA
                                                            await update_round_and_ball();

                                                            return;
                                                          }
                                                          else {
                                                            //SALVANDO AS NOVAS CONFIG DA SALA E VOLTANDO PARA O HOST

                                                            updates_player = {};
                                                            room_config_updates =
                                                            {};

                                                            updates_player['preference'] =
                                                            true;

                                                            room_config_updates['name_playing'] =
                                                            _room_data.data
                                                                .data()['user_name_host'];

                                                            await FirebaseFirestore
                                                                .instance
                                                                .collection(
                                                                'rooms')
                                                                .doc(
                                                                user_local['room'])
                                                                .collection(
                                                                'participants')
                                                                .doc(_room_data
                                                                .data
                                                                .data()['uid_host'])
                                                                .update(
                                                                updates_player);

                                                            await FirebaseFirestore
                                                                .instance
                                                                .collection(
                                                                'rooms')
                                                                .doc(
                                                                user_local['room'])
                                                                .update(
                                                                room_config_updates);

                                                            //ADICIONANDO NOVO NUMERO BOLINHAS DIPONIVEL POR RODADA NA PARTIDA
                                                            await update_round_and_ball();
                                                          }
                                                        }

                                                        //SORTEANDO NOVOS NUMEROS PARA O JOGADOR
                                                        bool get_result =
                                                        await sorting_number();

                                                        if (get_result ==
                                                            true) {
                                                          set_winner(
                                                              user_local['name']);

                                                          setState(() {
                                                            button_lock = true;
                                                          });

                                                          return;
                                                        } else {
                                                          //ATUALIZANDO AS CONFIG DA SALA APOS JOGADA
                                                          await update_room_state();

                                                          //PEGANDO OS DADOS DO JOGADOR ATUAL E ATUALIZANDO
                                                          await update_player_state();

                                                          //DANDO PREFERENCIA PARA O PROXIMO JOGADOR
                                                          await get_next_player();

                                                          setState(() {
                                                            button_lock = true;
                                                          });
                                                        }
                                                      }
                                                      on_sort_balls();
                                                    } else {
                                                      return;
                                                    }
                                                  } else {
                                                    message_room_players_empty(
                                                        context);
                                                  }
                                                },
                                                child: Container(
                                                    decoration: BoxDecoration(
                                                        color: _room_data.data
                                                            .data()[
                                                        'name_playing'] ==
                                                            user_local['name'] &&
                                                            button_lock == true
                                                            ? Colors.blue
                                                            : Colors.grey,
                                                        borderRadius:
                                                        BorderRadius.circular(
                                                            5)),
                                                    alignment: Alignment.center,
                                                    width: double.maxFinite,
                                                    padding: EdgeInsets
                                                        .symmetric(
                                                        vertical: 16),
                                                    child: Text(
                                                      "JOGAR",
                                                      style:
                                                      TextStyle(
                                                          color: Colors.white),
                                                    )),
                                              ),
                                            ) :
                                            Padding(
                                              padding: EdgeInsets.only(
                                                  right: 5, left: 10, top: 10),
                                              child: InkWell(
                                                onTap: () async {
                                                  if (user_local['name'] ==
                                                      _room_data.data
                                                          .data()['user_name_host']) {
                                                    await restart_game();
                                                  }
                                                },
                                                child: Container(
                                                    decoration: BoxDecoration(
                                                        color: Colors.green,
                                                        borderRadius:
                                                        BorderRadius.circular(
                                                            5)),
                                                    alignment: Alignment.center,
                                                    width: double.maxFinite,
                                                    padding: EdgeInsets
                                                        .symmetric(
                                                        vertical: 16),
                                                    child: Text(
                                                      user_local['name'] ==
                                                          _room_data.data
                                                              .data()['user_name_host']
                                                          ?
                                                      "REINICIAR PARTIDA"
                                                          : "JOGADOR ${_room_data
                                                          .data
                                                          .data()['user_winner']
                                                          .toString()
                                                          .toUpperCase()} GANHOU!!",
                                                      style:
                                                      TextStyle(
                                                          color: Colors.white),
                                                    )),
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.only(
                                                  left: 10, top: 10, right: 5),
                                              child: Material(
                                                  borderRadius:
                                                  BorderRadius.circular(5),
                                                  elevation: 3,
                                                  shadowColor: Colors.black,
                                                  child: Column(
                                                    children: [
                                                      Padding(
                                                        padding: EdgeInsets
                                                            .only(
                                                            top: 10, bottom: 5),
                                                        child: Text(
                                                          'NÚMEROS SORTEADOS',
                                                          style: TextStyle(
                                                              fontSize: 15.4,
                                                              color: Colors
                                                                  .grey),
                                                        ),
                                                      ),
                                                      ResponsiveGridList(
                                                        desiredItemWidth: 50,
                                                        minSpacing: 5,
                                                        scroll: false,
                                                        children: List.generate(
                                                          numbers_sorted.length,
                                                              (index) =>
                                                              RawMaterialButton(
                                                                constraints:
                                                                BoxConstraints
                                                                    .expand(
                                                                    width: 45,
                                                                    height: 50),
                                                                onPressed: () {},
                                                                elevation: 2.0,
                                                                fillColor: numbers_sorted[
                                                                index]
                                                                ['color'] ==
                                                                    'red'
                                                                    ? Colors.red
                                                                    : numbers_sorted[
                                                                index]
                                                                [
                                                                'color'] ==
                                                                    'green'
                                                                    ? Colors
                                                                    .green
                                                                    : Colors
                                                                    .blue,
                                                                child: Text(
                                                                  '${numbers_sorted[index]['number']}',
                                                                  style: TextStyle(
                                                                      fontSize: 13,
                                                                      color:
                                                                      Colors
                                                                          .white),
                                                                ),
                                                                shape: CircleBorder(),
                                                              ),
                                                        ),
                                                      ),
                                                    ],
                                                  )),
                                            ),
                                            Padding(
                                                padding: EdgeInsets.only(
                                                    left: 10,
                                                    top: 10,
                                                    right: 5),
                                                child: Material(
                                                  borderRadius: BorderRadius
                                                      .circular(5),
                                                  elevation: 3,
                                                  shadowColor: Colors.black,
                                                  child: Padding(
                                                      padding: EdgeInsets.all(
                                                          10),
                                                      child: _room_data.data
                                                          .data()[
                                                      'host_in_room'] ==
                                                          true
                                                          ? _room_data.data
                                                          .data()[
                                                      'user_winner'] ==
                                                          null
                                                          ? _room_data.data
                                                          .data()[
                                                      'name_playing'] ==
                                                          user_local['name']
                                                          ? Text(
                                                        'É A SUA VEZ DE JOGAR!!',
                                                        style: TextStyle(
                                                            fontSize: 16,
                                                            color: Colors
                                                                .green),
                                                      )
                                                          : Text(
                                                        'AGUARDE O JOGADOR ${_room_data
                                                            .data
                                                            .data()['name_playing']
                                                            .toString()
                                                            .toUpperCase()} JOGAR',
                                                        style: TextStyle(
                                                            fontSize: 16,
                                                            color: Colors
                                                                .grey),
                                                      )
                                                          : Row(
                                                          mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                          children: [
                                                            Text(
                                                              'O JOGADOR ${_room_data
                                                                  .data
                                                                  .data()['user_winner']
                                                                  .toString()
                                                                  .toUpperCase()} É O GANHADOR!!',
                                                              style: TextStyle(
                                                                  fontSize: 16,
                                                                  color: Colors
                                                                      .green),
                                                            ),
                                                            Icon(
                                                              Icons.style,
                                                              color:
                                                              Colors.green,
                                                            ),
                                                          ])
                                                          : Text(
                                                        'O Host saiu da sala.',
                                                        style: TextStyle(
                                                            fontSize: 16,
                                                            color: Colors.red),
                                                      )),
                                                )),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        child: ListView(
                                          children: [
                                            Padding(
                                                padding: EdgeInsets.only(
                                                    left: 10,
                                                    top: 10,
                                                    right: 10),
                                                child: Container(
                                                  constraints:
                                                  BoxConstraints(maxWidth: 500),
                                                  child: Column(
                                                    children: [
                                                      Column(
                                                        children: [
                                                          Material(
                                                              elevation: 3,
                                                              borderRadius: BorderRadius
                                                                  .circular(5),
                                                              shadowColor: Colors
                                                                  .black,
                                                              child: Column(
                                                                children: [
                                                                  Padding(
                                                                    padding:
                                                                    EdgeInsets
                                                                        .only(
                                                                        bottom: 5,
                                                                        top: 10),
                                                                    child: Text(
                                                                      'JOGADORES NA PARTIDA',
                                                                      style: TextStyle(
                                                                          fontSize: 15.4,
                                                                          color: Colors
                                                                              .grey),
                                                                    ),
                                                                  ),
                                                                  Column(
                                                                    children: List
                                                                        .generate(
                                                                        _participants_data
                                                                            .data
                                                                            .docs
                                                                            .length,
                                                                            (
                                                                            index) {
                                                                          return Padding(
                                                                              padding:
                                                                              EdgeInsets
                                                                                  .all(
                                                                                  5),
                                                                              child: Column(
                                                                                children: [
                                                                                  Row(
                                                                                    mainAxisAlignment:
                                                                                    MainAxisAlignment
                                                                                        .spaceBetween,
                                                                                    children: [
                                                                                      Row(
                                                                                        children: [
                                                                                          _participants_data
                                                                                              .data
                                                                                              .docs[index]
                                                                                              .data()['preference'] ==
                                                                                              true
                                                                                              ? Icon(
                                                                                            Icons
                                                                                                .videogame_asset,
                                                                                            color: Colors
                                                                                                .blue,
                                                                                          )
                                                                                              : Icon(
                                                                                            Icons
                                                                                                .account_circle,
                                                                                            color: Colors
                                                                                                .grey,
                                                                                          ),
                                                                                          SizedBox(
                                                                                            width: 5,
                                                                                          ),
                                                                                          Text(
                                                                                            '${_participants_data
                                                                                                .data
                                                                                                .docs[index]
                                                                                                .id ==
                                                                                                user_local['id']
                                                                                                ? '${_participants_data
                                                                                                .data
                                                                                                .docs[index]
                                                                                                .data()['user_name']} (Você)'
                                                                                                : _participants_data
                                                                                                .data
                                                                                                .docs[index]
                                                                                                .data()['user_name']}',
                                                                                            style: TextStyle(
                                                                                                fontSize: 14,
                                                                                                color: _participants_data
                                                                                                    .data
                                                                                                    .docs[index]
                                                                                                    .data()['preference'] ==
                                                                                                    true
                                                                                                    ? Colors
                                                                                                    .blue
                                                                                                    : Colors
                                                                                                    .grey),
                                                                                          )
                                                                                        ],
                                                                                      ),
                                                                                      _participants_data
                                                                                          .data
                                                                                          .docs[index]
                                                                                          .data()['preference'] ==
                                                                                          true
                                                                                          ? Text(
                                                                                        'Jogando...',
                                                                                        style: TextStyle(
                                                                                            fontSize: 14,
                                                                                            color: Colors
                                                                                                .blue),
                                                                                      )
                                                                                          : Text(
                                                                                        'Aguardando...',
                                                                                        style: TextStyle(
                                                                                            fontSize: 14,
                                                                                            color: Colors
                                                                                                .grey),
                                                                                      )
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
                                                )),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  Center(
                                    child: OpacityAnimatedWidget.tween(
                                        opacityEnabled: 1,
                                        opacityDisabled: 0,
                                        enabled: _room_data.data
                                            .data()['user_winner'] ==
                                            null ? false : true,
                                        //bind with the boolean
                                        child: Container(
                                          height: 150,
                                          child: Material(
                                              color: Colors.white,
                                              elevation: 10,
                                              borderRadius: BorderRadius
                                                  .circular(10),
                                              shadowColor: Colors.black,
                                              child: Column(
                                                children: [
                                                  SizedBox(height: 45,),
                                                  Icon(Icons.style,
                                                    color: Colors.green,),
                                                  SizedBox(height: 5,),
                                                  Padding(
                                                    padding: EdgeInsets.only(
                                                        left: 15, right: 15),
                                                    child: Text(
                                                      _room_data.data
                                                          .data()['user_winner'] !=
                                                          null
                                                          ?
                                                      "O JOGADOR ${_room_data
                                                          .data
                                                          .data()['user_winner']
                                                          .toString()
                                                          .toUpperCase()} É O GANHADOR!!"
                                                          :
                                                      "REINICIANDO PARTIDA...",
                                                      style: TextStyle(
                                                          fontSize: 17,
                                                          color: Colors.green,
                                                          fontWeight:
                                                          FontWeight.bold),
                                                      textAlign: TextAlign
                                                          .center,
                                                    ),
                                                  )
                                                ],
                                              )),
                                        )
                                    ),
                                  ),
                                  user_local['name'] ==
                                      _room_data.data.data()['user_name_host']
                                      ? Positioned(
                                      bottom: 0,
                                      right: 0,
                                      width: 150,
                                      height: 60,
                                      child: Padding(
                                        padding: EdgeInsets.all(5),
                                        child: FloatingActionButton(
                                          child: InkWell(
                                            onTap: () async {
                                              await restart_game();
                                            },
                                            child: Container(
                                                decoration: BoxDecoration(
                                                    color: Colors.red,
                                                    borderRadius:
                                                    BorderRadius.circular(20)),
                                                alignment: Alignment.center,
                                                width: double.maxFinite,
                                                padding:
                                                EdgeInsets.symmetric(
                                                    vertical: 16),
                                                child: Text(
                                                  "Reiniciar Jogo",
                                                  style: TextStyle(
                                                      color: Colors.white),
                                                )),
                                          ),
                                          onPressed: () {},
                                        ),
                                      )
                                  )
                                      : Container(),
                                ],
                              );
                          }catch(e){
                            return Container(
                              padding: EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.stretch,
                                mainAxisAlignment:
                                MainAxisAlignment.center,
                                children: <Widget>[
                                  Icon(
                                    Icons.info_outline,
                                    size: 96.0,
                                    color: Colors.black,
                                  ),
                                  SizedBox(
                                    height: 16.0,
                                  ),
                                  Text(
                                    "Carregando sala...",
                                    style: TextStyle(
                                        fontSize: 22.0,
                                        color: Colors.black,
                                        fontWeight:
                                        FontWeight.bold),
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(
                                    height: 16.0,
                                  ),
                                ],
                              ),
                            );
                          }
                        });
                });
          }),
    );
  }
}
