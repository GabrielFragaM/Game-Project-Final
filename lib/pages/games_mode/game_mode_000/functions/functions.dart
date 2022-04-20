import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../start_menu.dart';
import '../../../helpers/constants.dart';

///MUDA DE TELA
change_screen(context, screen){
  Navigator.of(context).push(
      MaterialPageRoute(
          builder: (context) =>
              screen
      ));
}

///ACRESCENTA ROUNDS E BOLINHAS A CADA RODADA
update_round_and_ball() async {
  Map <String, dynamic> room_config = {};

  DocumentSnapshot _room_data = await FirebaseFirestore.instance.collection('rooms')
      .doc(user_local['room']).get();

  QuerySnapshot _participants = await FirebaseFirestore.instance.collection('rooms')
      .doc(user_local['room']).collection('participants').get();

  //SE O NUMERO DE ROUNDS FOR IGUAL O NUMERO JOGADORES ACRESCENTA UMA BOLINHA E RESETA OS ROUNDS
  if(_room_data.data()['rounds'] == _participants.docs.length) {
    room_config['number_of_balls'] = _room_data.data()['number_of_balls'] += 1;
    room_config['rounds'] = 0;

    await FirebaseFirestore.instance.collection('rooms')
        .doc(user_local['room']).update(room_config);
  }
}

///RESETA O VENCEDOR DA SALA
reset_winner() async {
  Map <String, dynamic> room_config = {};

  room_config['user_winner'] = null;

  await FirebaseFirestore.instance.collection('rooms')
      .doc(user_local['room']).update(room_config);
}

///DEFININDO O VENCEDOR DA SALA
set_winner(user_name_winner) async {
  Map <String, dynamic> room_config = {};

  room_config['user_winner'] = user_name_winner;

  await FirebaseFirestore.instance.collection('rooms')
      .doc(user_local['room']).update(room_config);
}

///REMOVE UM PARTICIPANTE OU UM HOST DA SALA
quit_player(context, player, exit, id) async {

  if(id == null) {
    FirebaseFirestore.instance.collection('rooms')
        .doc(user_local['room']).collection('participants').doc(
        user_local['id']).delete();
  }else{
    FirebaseFirestore.instance.collection('rooms')
        .doc(user_local['room']).collection('participants').doc(
        id).delete();
  }

  Map <String, dynamic> room_config = {};

  //INDICANDO PARA A SALA SE O HOST SAIU
  if(player == 'host') {
    room_config['host_in_room'] = false;

    FirebaseFirestore.instance.collection('rooms')
        .doc(user_local['room']).update(room_config);
  }

  if(exit == true) {
    //MUDANDANDO PARA A PAGINA INICIAL
    change_screen(context, StartGame());
  }

}

///RESATA TODAS AS CONFIG PARA PADRAO DA SALA
restart_room(name_host) async {
  Map <String, dynamic> room_config = {};

  room_config['total_numbers_winner'] = 1;
  room_config['tied_game'] = false;
  room_config['name_playing'] = name_host;

  await FirebaseFirestore.instance.collection('rooms')
      .doc(user_local['room']).update(room_config);
}

///REINICIA O JOGO
restart_game() async {
  Map <String, dynamic> user_config = {};
  Map <String, dynamic> host_config = {};

  QuerySnapshot participants = await FirebaseFirestore.instance.collection('rooms')
      .doc(user_local['room']).collection('participants').get();

  DocumentSnapshot _room_data = await FirebaseFirestore.instance.collection('rooms')
      .doc(user_local['room']).get();

  //RESETANDO AS CONFIG DA SALA
  await restart_room(_room_data.data()['user_name_host']);
  await reset_numbers_player();
  await reset_winner();

  //DESTATIVANDO TODOS JOGADORES
  user_config['preference'] = false;
  user_config['plays'] = 0;
  user_config['in_game'] = true;

  //ATIVANDO NOVAMENTE O HOST PARA INICIAR A PARTIDA
  host_config['preference'] = true;
  host_config['plays'] = 0;
  host_config['in_game'] = true;

  //SALVANDO
  for(var player in participants.docs){
    //VERIFICANDO SE E UM PARTICIPANDO E NAO O HOST
    if(player.id != _room_data.data()['uid_host']){
      await FirebaseFirestore.instance.collection('rooms')
          .doc(user_local['room']).collection('participants').doc(player.id).update(user_config);
    }else{
      await FirebaseFirestore.instance.collection('rooms')
          .doc(user_local['room']).collection('participants').doc(_room_data.data()['uid_host']).update(host_config);
    }
  }
}

///DEFININDO UM EMPATE
define_tied(name_user_start) async {
  Map <String, dynamic> room_config = {};

  room_config['total_numbers_winner'] = 1;
  room_config['tied_game'] = true;
  room_config['name_playing'] = name_user_start;

  await reset_numbers_player();
  await FirebaseFirestore.instance.collection('rooms')
      .doc(user_local['room']).update(room_config);

}


///RESETANDO AS BOLINHAS SORTEADAS PELO JOGADOR
reset_numbers_player() async {
  QuerySnapshot participants = await FirebaseFirestore.instance.collection('rooms')
      .doc(user_local['room']).collection('participants').get();

  for(var pl in participants.docs){
    await FirebaseFirestore
        .instance.collection('rooms')
        .doc(user_local['room']).collection('participants').doc(pl.id)
        .collection('numbers').get().then((snapshot) {
      for (DocumentSnapshot ds in snapshot.docs){
        ds.reference.delete();
      }
    });
  }
}


