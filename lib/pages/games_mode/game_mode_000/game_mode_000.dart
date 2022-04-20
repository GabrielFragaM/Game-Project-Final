import 'dart:math';
import 'dart:html' as html;
import 'package:animated_widgets/widgets/opacity_animated.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:responsive_grid/responsive_grid.dart';
import '../../helpers/constants.dart';
import 'functions/functions.dart';
import '../../helpers/messages.dart';
import 'package:pausable_timer/pausable_timer.dart';
class GamePageMode000 extends StatefulWidget {
  @override
  GamePageMode000State createState() => GamePageMode000State();
}

class GamePageMode000State extends State<GamePageMode000> {

  bool button_lock = true;
  List numbers_sorted = [];
  List colors_sorted = [];

  ///RESETANDO OS NUMEROS DO VENCEDOR
  reset_numbers_and_colors() {
    setState(() {
      numbers_sorted = [];
      colors_sorted = [];
    });
  }

  ///PEGANDO TODOS OS JOGADORES DA SALA
  Future<QuerySnapshot>get_all_players() async {
    QuerySnapshot players = await FirebaseFirestore.instance
        .collection('rooms')
        .doc(user_local['room'])
        .collection('participants').get();

    return players;
  }
  Future<QuerySnapshot>all_players;

  AudioPlayer audioPlayer = AudioPlayer(mode: PlayerMode.MEDIA_PLAYER);

  ///INICIANDO A SALA
  @override
  void initState() {
    all_players = get_all_players();
    super.initState();
  }


  @override
  Widget build(BuildContext context) {

    try{
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
                await quit_player(context, user_local['host'] == true ? 'host' : 'player', true, null);

                DocumentSnapshot room_data = await FirebaseFirestore.instance.collection('rooms')
                    .doc(user_local['room']).get();

                //ATUALIZANDO A SALA DIZENDO QUE TEM UM JOGADOR A MENOS
                Map <String, dynamic> room_config = {};
                room_config['total_players'] = room_data.data()['total_players'] -= 1;
                FirebaseFirestore.instance.collection('rooms')
                    .doc(user_local['room']).update(room_config);

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

                if(_room_data.data.data()[
                'user_winner'] !=
                    null){
                  audioPlayer.play('http://commondatastorage.googleapis.com/codeskulptor-assets/week7-brrring.m4a');
                }

                //MONITORANDO SE O JOGADOR ESTA NA SALA
                html.window.onBeforeUnload.listen((event) async {
                  //SE O JOGADOR SAIR DA SALA EXCLUINDO TODAS AS INFORMACOES
                  if (event.type == 'beforeunload') {
                    quit_player(context, user_local['host'] == true ? 'host' : 'player', true, null);

                    //ATUALIZANDO A SALA DIZENDO QUE TEM UM JOGADOR A MENOS
                    Map <String, dynamic> room_config = {};
                    room_config['total_players'] = _room_data.data.data()['total_players'] -= 1;
                    FirebaseFirestore.instance.collection('rooms')
                        .doc(user_local['room']).update(room_config);
                  }
                });
              return FutureBuilder<QuerySnapshot>(
                  future: all_players,
                  builder: (context, _participants_data) {
                    if(_participants_data.connectionState == ConnectionState.waiting) return Container();
                    else
                      return StreamBuilder<DocumentSnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('rooms')
                              .doc(user_local['room'])
                              .collection('participants')
                              .doc(user_local['id'])
                              .snapshots(),
                          builder: (context, _participant_document) {
                            if(!_participant_document.hasData) return Container();
                            else
                              //TRIGGER DO JOGADOR PARA ATUALIZAR O ESTADO DO APP SEMPRE QUE ALGUM JOGADOR ENTRAR OU SAIR DA SALA
                            if(_participant_document.data.data()['total_players'] != _room_data.data.data()['total_players']){
                              Future.delayed(Duration.zero,() async {
                                Map <String, dynamic> player_update = {};

                                //DEFININDO O NUMERO DE JOGADORES ATUALIZADO DA SALA NOVAMENTE PARA O TRIGGER DO JOGADOR
                                player_update['total_players'] = _room_data.data.data()['total_players'];

                                await FirebaseFirestore.instance
                                    .collection('rooms')
                                    .doc(user_local['room'])
                                    .collection('participants')
                                    .doc(user_local['id']).update(player_update);

                                //ATUALIZANDO O ESTADO DO APP BUSCANDO OS NOVOS JOGADORES
                                setState(() {
                                  all_players = get_all_players();
                                });

                              });
                            }
                            return Stack(
                              children: <Widget>[
                                Container(
                                  child: ResponsiveGridList(
                                    desiredItemWidth: 250,
                                    minSpacing: 5,
                                    scroll: false,
                                    children: List.generate(
                                        _participants_data.data.docs.length,
                                            (index) =>
                                            Column(
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
                                                          .data.docs.length != 1
                                                          ) {

                                                        //VERIFICANDO SE E A VEZ DO JOGADOR
                                                        if (_room_data.data
                                                            .data()['name_playing'] ==
                                                            user_local['name'] &&
                                                            user_local['name'] == _participants_data.data.docs[index].data()['user_name'] &&
                                                            button_lock == true
                                                            ) {

                                                          setState(() {
                                                            button_lock = false;
                                                          });

                                                          on_click_button() async {

                                                            //REMOVENDO O STATUS DA PARTIDA DE EMPATE SE ACONTECEU UM EMPATE
                                                            if(_room_data.data.data()['tied_game'] == true){
                                                              Map <String, dynamic> tied_game = {};
                                                              tied_game['tied_game'] = false;
                                                              await FirebaseFirestore
                                                                  .instance
                                                                  .collection(
                                                                  'rooms')
                                                                  .doc(
                                                                  user_local['room'])
                                                                  .update(tied_game);

                                                            }

                                                            ///FUNCAO GERANDO NOVOS NUMEROS ALEATORIAMENTE PARA O JOGADOR
                                                            Future<bool> sorting_number() async {
                                                              final _random = Random();

                                                              //LISTA DE CORES
                                                              List red_colors = [];
                                                              List green_colors = [];
                                                              List blue_colors = [];

                                                              //LOOP COM NUMERO DE VOLTAS 30
                                                              for (var n = 1; n < 30; n++) {
                                                                //GERANDO AS CORES
                                                                var color = colors_sort[_random.nextInt(colors_sort.length)];

                                                                //SALVANDO OS NUMEROS EM UMA LISTA
                                                                colors_sorted.add(color);

                                                                //SALVANDO AS CORES NAS LISTAS PARA VERIFICAR QUANTAS IGUAIS EXISTEM
                                                                if (color ==
                                                                    'red') {
                                                                  red_colors.add(1);
                                                                } else if (color ==
                                                                    'green') {
                                                                  green_colors.add(1);
                                                                } else if (color ==
                                                                    'blue') {
                                                                  blue_colors.add(1);
                                                                }

                                                                //SALVANDO O NUMERO E A COR EM UM MAP PARA MOSTRAR NA TELA DO USUARIO
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

                                                                //SALVANDO O RESULTADO DAS BOLINHAS NO ONLINE
                                                                Map<String, dynamic> numbers_update_online = {};
                                                                numbers_update_online['number'] = n;
                                                                numbers_update_online['color'] = color;

                                                                final timer = PausableTimer(Duration(milliseconds: 500), () => print('Tempo!'));
                                                                timer.start();
                                                                await Future<void>.delayed(timer.duration * 1);
                                                                timer.reset();

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
                                                                    .add(numbers_update_online);

                                                                await audioPlayer.play('http://codeskulptor-demos.commondatastorage.googleapis.com/pang/pop.mp3');

                                                                //VERIFICANDO SE EXISTE 3 CORES IGUAIS DENTRO DA LISTA DAS CORES E PARANDO O LOOP
                                                                if (red_colors
                                                                    .length ==
                                                                    3 ||
                                                                    green_colors
                                                                        .length ==
                                                                        3 ||
                                                                    blue_colors
                                                                        .length ==
                                                                        3) {

                                                                  return true;
                                                                } else {
                                                                }
                                                              }
                                                            }

                                                            ///FUNCAO ATUALIZANDO AS INFORMACOES DO JOGADOR
                                                            Map<String, dynamic>updates_player = {};
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

                                                              QuerySnapshot numbers_of_player = await FirebaseFirestore
                                                                  .instance
                                                                  .collection(
                                                                  'rooms')
                                                                  .doc(user_local['room'])
                                                                  .collection(
                                                                  'participants')
                                                                  .doc(user_local['id']).collection('numbers')
                                                                  .get();

                                                              Map <String, dynamic> numbers_update = {};

                                                              //DEFININDO O NUMERO DE BOLINHAS DO JOGADOR PARA COMPARAR COM OS OUTROS PARA DEFINIR O GANHADOR
                                                              numbers_update['total_numbers_winner'] = numbers_of_player.docs.length;

                                                              //VERIFICANDO SE JA TEM UM JOGADOR COM UM MENOR NUMERO
                                                              if(_room_data.data.data()['total_numbers_winner'] == 1) {
                                                                await FirebaseFirestore
                                                                    .instance
                                                                    .collection(
                                                                    'rooms')
                                                                    .doc(user_local['room'])
                                                                    .update(numbers_update);
                                                              }else{
                                                                if(numbers_of_player.docs.length < _room_data.data.data()['total_numbers_winner']) {
                                                                  await FirebaseFirestore
                                                                      .instance
                                                                      .collection(
                                                                      'rooms')
                                                                      .doc(user_local['room'])
                                                                      .update(numbers_update);
                                                                }
                                                              }

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

                                                            ///FUNCAO ESCOLENDO O PROXIMO JOGADOR
                                                            Map<String, dynamic>room_config_updates = { };
                                                            get_next_player() async {
                                                              //BUSCANDO NOVO JOGADOR COM MENOR NUMERO DE JOGADAS
                                                              QuerySnapshot all_players = await FirebaseFirestore
                                                                  .instance
                                                                  .collection(
                                                                  'rooms')
                                                                  .doc(user_local['room']).collection('participants')
                                                                  .where('plays', isLessThan: updates_player['plays']).where('in_game', isEqualTo: true)
                                                                  .get();

                                                              Map<String, dynamic> updates_next_player = {};
                                                              room_config_updates = {};

                                                              //SE NAO ACHAR PROXIMO JOGADOR A PARTIDA ACABA E VERIFICA SE EXISTE UM EMPATE
                                                              if (all_players.docs.length != 0) {
                                                                //MUDANDO A PREFERENCIA PARA O JOGADOR
                                                                updates_next_player['preference'] = true;

                                                                //SALVANDO QUEM JOGARA NA PROXIMA PARTIDA PARA AS CONFIG DA SALA

                                                                  room_config_updates['name_playing'] = all_players.docs[0].data()['user_name'];

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

                                                                setState(() {
                                                                  button_lock = true;
                                                                });

                                                                return;
                                                              }
                                                              else {

                                                                DocumentSnapshot room_number_balls = await FirebaseFirestore.instance
                                                                    .collection('rooms')
                                                                    .doc(user_local['room']).get();

                                                                for(var pl in _participants_data.data.docs){
                                                                  updates_player = {};

                                                                  QuerySnapshot player_numbers = await FirebaseFirestore.instance
                                                                      .collection('rooms')
                                                                      .doc(user_local['room'])
                                                                      .collection('participants').doc(pl.id).collection('numbers').get();

                                                                  //QUEM NAO FOR CLASSIFICADO PARA O EMPATE IRA SAIR DA RODADA
                                                                  if(player_numbers.docs.length == room_number_balls.data()['total_numbers_winner']){
                                                                    updates_player['in_game'] = true;
                                                                  }else{
                                                                    updates_player['in_game'] = false;
                                                                  }

                                                                  await FirebaseFirestore.instance
                                                                      .collection('rooms')
                                                                      .doc(user_local['room'])
                                                                      .collection('participants').doc(pl.id).update(updates_player);

                                                                }

                                                                //PEGANDO OS PLAYERS QUE AINDA ESTAO NO EMPATE
                                                                QuerySnapshot players_in_game = await FirebaseFirestore.instance
                                                                    .collection('rooms')
                                                                    .doc(user_local['room'])
                                                                    .collection('participants').where('in_game', isEqualTo: true).get();

                                                                //SE EXISTIR SO UM A PARTIDA ACABA SE NAO SERA DEFINIDO UM PARTIDA DE EMPATE
                                                                if(players_in_game.docs.length == 1){
                                                                  set_winner(players_in_game.docs[0].data()['user_name']);

                                                                  //SALVANDO AS NOVAS CONFIG DA SALA E VOLTANDO PARA O HOST
                                                                  updates_player = {};
                                                                  room_config_updates = {};

                                                                  updates_player['preference'] = true;

                                                                  room_config_updates['name_playing'] = _room_data.data.data()['user_name_host'];

                                                                  await FirebaseFirestore.instance.collection('rooms')
                                                                      .doc(user_local['room'])
                                                                      .collection('participants')
                                                                      .doc(_room_data.data.data()['uid_host']).update(updates_player);

                                                                  await FirebaseFirestore.instance
                                                                      .collection('rooms')
                                                                      .doc(user_local['room'])
                                                                      .update(room_config_updates);

                                                                }else{
                                                                  updates_player = {};

                                                                  updates_player['preference'] = true;

                                                                  await FirebaseFirestore.instance.collection('rooms')
                                                                      .doc(user_local['room'])
                                                                      .collection('participants')
                                                                      .doc(players_in_game.docs[0].id).update(updates_player);

                                                                  await define_tied(players_in_game.docs[0].data()['user_name']);
                                                                }
                                                                setState(() {
                                                                  button_lock = true;
                                                                });

                                                              }
                                                            }

                                                            //SORTEANDO NOVOS NUMEROS PARA O JOGADOR
                                                            await sorting_number();
                                                            //PEGANDO OS DADOS DO JOGADOR ATUAL E ATUALIZANDO
                                                            await update_player_state();
                                                            //DANDO PREFERENCIA PARA O PROXIMO JOGADOR
                                                            await get_next_player();



                                                          }
                                                          on_click_button();

                                                        } else {

                                                          return;
                                                        }
                                                      } else {
                                                        message_room_players_empty(context);
                                                      }


                                                    },
                                                    child: Container(
                                                        decoration: BoxDecoration(
                                                            color: _room_data.data
                                                                .data()['name_playing'] ==
                                                                user_local['name'] &&
                                                                user_local['name'] == _participants_data.data.docs[index].data()['user_name'] &&
                                                                button_lock == true
                                                                ? Colors.green
                                                                : _room_data.data
                                                                .data()['name_playing'] == _participants_data.data.docs[index].data()['user_name']  ?
                                                            Colors.blue : Colors.grey,
                                                            borderRadius:
                                                            BorderRadius.circular(
                                                                5)),
                                                        alignment: Alignment.center,
                                                        width: double.maxFinite,
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                            vertical: 16),
                                                        child: Text(
                                                          _room_data.data
                                                              .data()['name_playing'] ==
                                                              user_local['name'] &&
                                                              user_local['name'] == _participants_data.data.docs[index].data()['user_name'] ?
                                                          "JOGAR" : _participants_data.data.docs[index].data()['user_name'],
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
                                                            color: _room_data.data.data()['user_winner'] != _participants_data.data.docs[index].data()['user_name']
                                                                ? Colors.red : Colors.green,
                                                            borderRadius:
                                                            BorderRadius.circular(
                                                                5)),
                                                        alignment: Alignment.center,
                                                        width: double.maxFinite,
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                            vertical: 16),
                                                        child: Text(
                                                          _room_data.data.data()['user_winner'] != _participants_data.data.docs[index].data()['user_name']
                                                               ? "PERDEU" :
                                                          user_local['name'] ==
                                                              _room_data.data
                                                                  .data()['user_name_host']
                                                              ?
                                                          "REINICIAR PARTIDA"
                                                              :
                                                          user_local['name'] ==
                                                          _participants_data.data.docs[index].data()['user_name'] ?
                                                              "PARABÉNS VOCÊ GANHOU!!!" :
                                                          "JOGADOR ${_room_data
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
                                                    child: Container(
                                                      height: 200,
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
                                                              StreamBuilder<QuerySnapshot>(
                                                                  stream: FirebaseFirestore
                                                                      .instance.collection('rooms')
                                                                      .doc(user_local['room']).collection('participants').doc(_participants_data.data.docs[index].id)
                                                                      .collection('numbers').orderBy('number', descending: false)
                                                                      .snapshots(),
                                                                  builder: (context, numbers) {
                                                                    if (numbers.data == null) return Container();

                                                                    return ResponsiveGridList(
                                                                      desiredItemWidth: 45,
                                                                      minSpacing: 2,
                                                                      scroll: false,
                                                                      children: List.generate(
                                                                        numbers.data.docs.length,
                                                                            (index) =>
                                                                            RawMaterialButton(
                                                                              constraints: BoxConstraints
                                                                                  .expand(
                                                                                  width: 45, height: 45),
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
                                                          )),
                                                    )
                                                ),
                                                _room_data.data
                                                    .data()['name_playing'] == _participants_data.data.docs[index].data()['user_name']  ?
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
                                                        child: Text(
                                                          user_local['name'] == _participants_data.data.docs[index].data()['user_name']  ?
                                                          'AGORA É A SUA VEZ DE JOGAR!!' :
                                                          'AGUARDE O JOGADOR JOGAR...',
                                                          style: TextStyle(
                                                              fontSize: 16,
                                                              color: _room_data.data
                                                                  .data()['name_playing'] == _participants_data.data.docs[index].data()['user_name'] ?
                                                              Colors
                                                                  .green : Colors.blue),
                                                        )),
                                                  ),) : Container(),
                                              ],
                                            )
                                    ),
                                  ),
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
                                Center(
                                  child: OpacityAnimatedWidget.tween(
                                      opacityEnabled: 1,
                                      opacityDisabled: 0,
                                      enabled: _room_data.data
                                          .data()['tied_game'],
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
                                                        .data()['tied_game'] ==
                                                        true
                                                        ?
                                                    "PARECE QUE TEMOS UM EMPATE..."
                                                        :
                                                    "INICIANDO RODADA DE DESEMPATE",
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
                                user_local['name'] == _room_data.data.data()['user_name_host'] ?
                                Positioned(
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
                                ) :
                                Container(),
                              ],
                            );
                          });
                  });

            }),
      );
    }catch(e){
      return Container(child: Text('$e'),);
    }
  }
}
