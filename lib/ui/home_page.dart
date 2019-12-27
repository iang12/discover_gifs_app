import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gifts_search_app/ui/gif_detail.dart';
import 'package:http/http.dart' as http;
import 'package:share/share.dart';
import 'package:transparent_image/transparent_image.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String _search;

  int _offset = 0;

  Future<Map> _getGifs() async {
    http.Response response;

    if(_search == null || _search.isEmpty)
      response = await http.get("https://api.giphy.com/v1/gifs/trending?api_key=567oSthJPBSbCNYu9bpVrbgml0jA2JaY&limit=20&rating=G");
    else
      response = await http.get("https://api.giphy.com/v1/gifs/search?api_key=567oSthJPBSbCNYu9bpVrbgml0jA2JaY&q=$_search&limit=19&offset=$_offset&rating=G&lang=en");

    return json.decode(response.body);
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getGifs().then((data) {
      print(data);
    });
  }

  int _getCount(List data) {
    if (_search == null) {
      return data.length;
    } else {
      return data.length + 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Discover Gifts',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(
              Icons.shutter_speed,
              color: Colors.black,
            ),
          )
        ],
      ),
      body: Column(
        children: <Widget>[
          Container(
            margin: EdgeInsets.all(10),
            decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey,
                ),
                borderRadius: BorderRadius.circular(20),
                color: Colors.transparent),
            child: TextField(
              decoration: InputDecoration(
                  border: InputBorder.none,
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.grey,
                    size: 25,
                  ),
                  hintText: 'Pesquise Aqui',
                  hintStyle: TextStyle(color: Colors.grey, fontSize: 18.0)),
              onSubmitted: (s) {
                setState(() {
                  _search = s;
                  _offset = 0;
                });
              },
            ),
          ),
          Expanded(
            child: FutureBuilder<Map>(
              future: _getGifs(),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.none:
                  case ConnectionState.waiting:
                    return Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 3.0,
                      ),
                    );
                  default:
                    if (snapshot.hasError) {
                      return Container(
                        child: Text('ocorreu um erro'),
                      );
                    } else {
                      return _createGiftTable(context, snapshot);
                    }
                }
              },
            ),
          )
        ],
      ),
    );
  }

  Widget _createGiftTable(BuildContext context, AsyncSnapshot snapshot) {
    return GridView.builder(
        padding: EdgeInsets.all(20),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10.0,
          mainAxisSpacing: 10.0,
        ),
         itemCount: _getCount(snapshot.data['data']),
        itemBuilder: (context, index) {
          if (_search == null ||
              _search.isEmpty ||
              index < snapshot.data['data'].length)
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext context) =>
                          GifPage(snapshot.data['data'][index])));
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: FadeInImage.memoryNetwork(
                  placeholder: kTransparentImage,
                  image: snapshot.data['data'][index]['images']['fixed_height']
                      ['url'],
                  height: 300.0,
                  fit: BoxFit.cover,
                ),
              ),
              onLongPress: () {
                Share.share(
                    snapshot.data['data']['images']['fixed_height']['url']);
              },
            );
          else
            return Container(
              child: GestureDetector(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      Icons.add,
                      size: 70,
                    ),
                    Text(
                      'Carregar mais',
                      style: TextStyle(fontSize: 20.0, color: Colors.white),
                    ),
                  ],
                ),
                onTap: () {
                  setState(() {
                    _offset += 19;
                  });
                },
              ),
            );
        });
  }
}
