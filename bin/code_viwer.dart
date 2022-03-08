import 'dart:convert';
import 'dart:io';

import 'package:nyxx/nyxx.dart';
import 'package:http/http.dart' as http;

void main() {
  final bot = NyxxFactory.createNyxxWebsocket(
      'ODczMzY4MjQ0NDcwMzAwNzEy.YQ3Zjw.bbx3iFTNuR-w5_4RuKwZknQy_54',
      GatewayIntents.allUnprivileged)
    ..registerPlugin(Logging())
    ..registerPlugin(CliIntegration())
    ..registerPlugin(IgnoreExceptions())
    ..connect();

  bot.eventsWs.onMessageReceived.listen((event) {
    var text = event.message.content;
    var urlList = RegExp('https://github.com/(.*)#L[0-9]+(|　| |\n|\r\n)')
        .allMatches(text);
    urlList.forEach((urlMatch) {
      var url = urlMatch.group(0)!;
      var line = int.parse(url.replaceAll(RegExp('(.*)#L'), ''));
      var rawDataUrl = url
          .replaceFirst('blob/', '')
          .replaceAll(RegExp('#(.*)'), '')
          .replaceAll(
              'https://github.com', 'https://raw.githubusercontent.com');
      var rawDataUri = Uri.parse(rawDataUrl);

      http.get(rawDataUri).then((response) {
        var codeAsList = response.body.split('\n');
        var startLine = line - 1;
        var endLine = line + 10;
        if (codeAsList.length < endLine) {
          var endLine = codeAsList.length;
        }

        var code = codeAsList.sublist(startLine, endLine).join('%250A');

        http
            .get(Uri.parse('https://carbonnowsh.herokuapp.com/?code=$code&theme=One Light&lineNumbers=true&firstLineNumber=1&widthAdjustment=true&windowControls=false&paddingHorizontal=0px&paddingVertical=0px'))
            .then((response) {
          print(response.statusCode);
          var file = File('image.png');
          file.writeAsBytes(response.bodyBytes).then((value) {
            event.message.channel.sendMessage(
                MessageBuilder.files([AttachmentBuilder.file(file)]));
            event.message.suppressEmbeds();
          });
        });
      });
    });
  });
}
