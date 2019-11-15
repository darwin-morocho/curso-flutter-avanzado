import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_advanced_maps/api/nominatim.dart';
import 'package:flutter_advanced_maps/models/search_result.dart';

class Toolbar extends StatefulWidget {
  final double containerHeight;
  final Function(SearchResult) onSearch;
  final VoidCallback onGoMyPosition, onClear;

  const Toolbar(
      {Key key,
      @required this.onSearch,
      this.onGoMyPosition,
      this.containerHeight,
      this.onClear})
      : super(key: key);

  @override
  _ToolbarState createState() => _ToolbarState();
}

class _ToolbarState extends State<Toolbar> {
  var _query = '';
  final _nominatim = Nominatim();
  List<SearchResult> _items = List();
  final TextEditingController _textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _nominatim.onSearch = (List<SearchResult> data) {
      print("onSearch:  $data");
      setState(() {
        _items = data;
      });
    };
  }

  _onChanged(String text) async {
    _query = text;
    setState(() {});

    if (_query.trim().length > 0) {
      setState(() {
        _items.clear();
      });
      await _nominatim.search(_query);
    }
  }

  @override
  void dispose() {
    _nominatim.dispose();
    _textEditingController.dispose();
    super.dispose();
  }

  _clear() {
    setState(() {
      _query = '';
      _items.clear();
    });
    _textEditingController.clear();
    widget.onClear();
  }

  @override
  Widget build(BuildContext context) {
    final isNotEmpty = _query.trim().length > 0;
    return Container(
      height: widget.containerHeight,
      padding: EdgeInsets.all(15),
      child: Column(
        children: <Widget>[
          CupertinoTextField(
            controller: _textEditingController,
            placeholder: "Buscar lugar o establecimiento...",
            onChanged: _onChanged,
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
            style: TextStyle(color: Colors.black54, letterSpacing: 1),
            decoration: BoxDecoration(color: Color(0xfff0f0f0)),
            suffix: isNotEmpty
                ? CupertinoButton(
                    onPressed: _clear,
                    child: Icon(Icons.clear),
                  )
                : null,
          ),
          SizedBox(
            height: 10,
          ),
          isNotEmpty
              ? Expanded(
                  child: Container(
                    child: ListView.builder(
                      itemCount: _items.length,
                      itemBuilder: (context, index) {
                        final item = _items[index];
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            CupertinoButton(
                              onPressed: () {
                                widget.onSearch(item);
                                _clear();
                              },
                              child: Text(
                                item.displayName,
                                style: TextStyle(
                                    color: Colors.black54, fontSize: 15),
                              ),
                              padding: EdgeInsets.symmetric(vertical: 15),
                            ),
                            Container(
                              height: 1,
                              color: Color(0xffcccccc),
                            )
                          ],
                        );
                      },
                    ),
                  ),
                )
              : Container()
        ],
      ),
    );
  }
}
