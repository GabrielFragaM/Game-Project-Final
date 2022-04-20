
import 'dart:html';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:game_project/pages/games_mode/game_mode_000/game_mode_000.dart';
import 'package:game_project/pages/helpers/messages.dart';

import 'games_mode/game_mode_001/game_mode_001.dart';
import 'helpers/constants.dart';
import 'games_mode/game_mode_001/functions/functions.dart';


class StartGame extends StatefulWidget {

  @override
  StartGameState createState() =>
      StartGameState();
}

class StartGameState extends State<StartGame> {

  String input_text_name = '';
  String input_text_room = '';

  bool is_loading = false;
  bool is_loading2 = false;

  final Storage _localStorage = window.localStorage;
  ///SALVANDO AS INFO DO PARTICIPANTE NO STORAGE LOCAL DO NAVEGADOR
  Future save_local_storage(name, id, room, host) async {
    _localStorage['name'] = name;
    _localStorage['id'] = id;
    _localStorage['room'] = room;
    _localStorage['host'] = host;
  }


  ///CRIANDO UM NOVO PARTICIPANTE PARA SALVAR NA SALA
  define_participant_config(input_text_name, DocumentSnapshot room_data) async {
    Map <String, dynamic> user_config = {};
    Map <String, dynamic> room_config = {};

    //ADICIONANDO O JOGADOR A SALA
    room_config['total_players'] = room_data.data()['total_players'] += 1;

    await FirebaseFirestore.instance.collection('rooms')
        .doc(room_data.id).update(room_config);

    QuerySnapshot players = await FirebaseFirestore.instance.collection('rooms')
        .doc(room_data.id).collection('participants').get();

    ///DEFININDO CONFIGS INICIAIS DO USER
    user_config['user_name'] = input_text_name;
    user_config['preference'] = false;
    user_config['plays'] = 0;
    user_config['host'] = false;
    user_config['in_game'] = true;
    user_config['total_players'] = players.docs.length += 1;

    return user_config;
  }

  ///CRIANDO UM NOVO HOST PARA SALVAR NA SALA
  define_host_config(input_text_name){
    Map <String, dynamic> user_config = {};

    ///DEFININDO CONFIGS INICIAIS DO USER
    user_config['user_name'] = input_text_name;
    user_config['preference'] = true;
    user_config['plays'] = 0;
    user_config['host'] = true;
    user_config['in_game'] = true;
    user_config['total_players'] = 1;

    return user_config;
  }

  ///CRIANDO UMA NOVA SALA
  define_room_config(input_text_name){
    Map <String, dynamic> room_config = {};
    final _random =  Random();

    ///DEFININDO CONFIGS INICIAIS DA SALA
    room_config['room'] = _random.nextInt(9999).toString();
    room_config['uid_host'] = _random.nextInt(999999999).toString();
    room_config['user_name_host'] = input_text_name;
    room_config['user_winner'] = null;
    room_config['host_in_room'] = true;
    room_config['total_players'] = 1;
    room_config['total_numbers_winner'] = 1;
    room_config['tied_game'] = false;

    ///NUMERO DE BOLINHAS NO INICIO DO GAME
    room_config['number_of_balls'] = 4;

    ///NUMERO DE RODADAS
    room_config['rounds'] = 0;

    ///NOME DO JOGADOR QUE COMECARA JOGANDO
    room_config['name_playing'] = input_text_name;

    return room_config;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
        constraints: BoxConstraints(maxWidth: 600),
          child: Padding(
            padding: EdgeInsets.only(right: 20, left: 20),
            child: ListView(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top: 150, bottom: 5),
                  child: Icon(
                  Icons.videogame_asset,
                  size: 96.0,
                  color: Colors.black,
                ),
                ),
                Text(
                  "Iniciar Jogo v2.2",
                  style: TextStyle(
                      fontSize: 22.0,
                      color: Colors.black,
                      fontWeight:
                      FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                Padding(
                  padding: EdgeInsets.only(top: 45, bottom: 10),
                  child: Material(
                    elevation: 5.0,
                    borderRadius: BorderRadius.circular(20),
                    shadowColor: Colors.black,
                    child: TextField(
                      onChanged: (valor) async {
                        setState(() {
                          input_text_name = valor;
                        });
                      },
                      autofocus: false,
                      style: TextStyle(
                          fontSize: 15.0, color: Colors.black),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide(
                            width: 0,
                            style: BorderStyle.none,
                          ),
                        ),
                        contentPadding: EdgeInsets.only(
                            left: 14.0, bottom: 8.0, top: 8.0),
                        suffixIcon: Icon(
                            Icons.account_circle),
                        labelText: "Nome",
                        hintText: "Nome",
                      ),
                    ),
                  ),
                ),

                Padding(
                  padding: EdgeInsets.only(bottom: 10),
                  child: InkWell(
                    onTap: () async {
                      setState(() {
                        is_loading = true;
                      });

                      if(input_text_name != ''){

                        //CRIANDO UMA NOVA SALA E UM NOVO HOST
                        Map <String, dynamic> room_config = define_room_config(input_text_name + ' ' + '(Host)');
                        Map <String, dynamic> host_config = define_host_config(input_text_name + ' ' + '(Host)');

                        Random _random = Random();

                        room_config['room'] = _random.nextInt(99999).toString();

                        //SALVANDO
                        await FirebaseFirestore.instance.collection('rooms')
                            .doc(room_config['room']).set(room_config);

                        //SETANDO
                        await FirebaseFirestore.instance.collection('rooms')
                            .doc(room_config['room']).collection('participants').doc(room_config['uid_host']).set(host_config);

                        //SALVANDO AS INFO DO HOST NA WEB TEMPORARIO
                        setState((){
                          user_local['name'] = input_text_name + ' ' + '(Host)';
                          user_local['id'] = room_config['uid_host'];
                          user_local['room'] = room_config['room'];
                          user_local['host'] = true;
                        });
                        await save_local_storage(input_text_name, room_config['uid_host'], input_text_room, 'true');

                        message_choose_game_type(context);

                      }else{
                        message_name_empty(context);
                      }

                      setState(() {
                        is_loading = false;
                      });

                    },
                    child: Container(
                      decoration: BoxDecoration(color: Colors.blue,
                          borderRadius: BorderRadius.circular(20)),
                      alignment: Alignment.center,
                      width: double.maxFinite,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: is_loading == false ? Text("Criar Sala", style: TextStyle(color: Colors.white),)
                          : Container(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(color: Colors.white,)
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 110),
                  child: InkWell(
                    onTap: () async {

                      setState(() {
                        is_loading2 =true;
                      });

                      //PROCURANDO A SALA
                      QuerySnapshot rooms =  await FirebaseFirestore.instance.collection('rooms')
                          .where('room', isEqualTo: input_text_room).get();

                      if(input_text_name != ''){
                        if(rooms.docs.length != 0){

                          //CRIANDO PARTICIPANTE
                          Map <String, dynamic> user_config = await define_participant_config(input_text_name, rooms.docs[0]);

                          //SALVANDO
                          DocumentReference _user = await FirebaseFirestore.instance.collection('rooms')
                              .doc(rooms.docs[0].id).collection('participants').add(user_config);

                          //SALVANDO AS INFO DO PARTICIPANTE NO STORAGE DO NAVEGADOR
                          setState((){
                            user_local['name'] = input_text_name;
                            user_local['id'] = _user.id;
                            user_local['room'] = input_text_room;
                            user_local['host'] = false;
                          });
                          await save_local_storage(input_text_name, _user.id, input_text_room, 'false');

                          if(rooms.docs[0].data()['game_mode'] == 1) {
                            //MUDANDANDO PARA A PAGINA DA SALA DO JOGO
                            change_screen(context, GamePageMode001());
                          }else{
                            //MUDANDANDO PARA A PAGINA DA SALA DO JOGO
                            change_screen(context, GamePageMode000());
                          }
                        }else{
                          message_room_not_found(context);
                        }
                      }else{
                        message_name_empty(context);
                      }

                      setState(() {
                        is_loading2 = false;
                      });


                    },
                    child: Container(
                      decoration: BoxDecoration(color: Colors.blue,
                          borderRadius: BorderRadius.circular(20)),
                      alignment: Alignment.center,
                      width: double.maxFinite,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: is_loading2 == false ? Text("Entrar em uma Sala", style: TextStyle(color: Colors.white))
                          : Container(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(color: Colors.white,)
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        ))
    );
  }

}