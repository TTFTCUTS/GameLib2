import "dart:async";
import "dart:html";

import 'package:GameLib2/GameLib2.dart';

main() async {
    new Audio("", querySelector("#subs"));
    Audio.INSTANCE.icreateChannel("main");

    await Loader.getResource(Audio.INSTANCE.processSoundName("boydhurt1"));

    querySelector("#boop")..onClick.listen((Event e){
        Audio.play("boydhurt1", "main", subtitle: "Ouch!", pitchVar: 0.5);
    });
}
