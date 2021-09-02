import 'package:flutter/material.dart';

import 'package:My_Day_app/public/note_request/share.dart';
import 'package:My_Day_app/models/note/share_note_list_model.dart';
import 'package:My_Day_app/public/note_request/get_group_list.dart';
import 'package:My_Day_app/public/note_request/get_list.dart';
import 'package:My_Day_app/group/customer_check_box.dart';
import 'package:My_Day_app/models/note/note_list.dart';

class ShareNotePage extends StatefulWidget {
  int groupNum;
  ShareNotePage(this.groupNum);

  @override
  _ShareNoteWidget createState() => new _ShareNoteWidget(groupNum);
}

class _ShareNoteWidget extends State<ShareNotePage> {
  int groupNum;
  _ShareNoteWidget(this.groupNum);

  List _noteListModel = [];
  ShareNoteListModel _shareNoteList;

  String uid = 'lili123';
  int noteNum;

  List _noteCheck = [];

  bool _isEnabled;

  @override
  void initState() {
    super.initState();
    _noteListRequest();
    _buttonIsOnpressed();
  }

  _buttonIsOnpressed() {
    int count = 0;
    for (int i = 0; i < _noteCheck.length; i++) {
      if (_noteCheck[i] == true) {
        count++;
      }
    }
    if (count != 0) {
      setState(() {
        _isEnabled = true;
      });
    } else {
      setState(() {
        _isEnabled = false;
      });
    }
  }

  _noteListRequest() async {
    // var response =
    //     await rootBundle.loadString('assets/json/share_note_list.json');
    // var responseBody = json.decode(response);
    // var groupNoteListModel = ShareNoteListModel.fromJson(responseBody);

    ShareNoteListModel _shareNoteListRequest =
        await GetGroupList(uid: uid, groupNum: groupNum).getData();

    NoteListModel _noteList = await GetList(uid: uid).getData();

    setState(() {
      _shareNoteList = _shareNoteListRequest;
      for (int i = 0; i < _noteList.note.length; i++) {
        int count = 0;
        var note = _noteList.note[i];
        for (int j = 0; j < _shareNoteList.note.length; j++) {
          var groupNote = _shareNoteList.note[j];
          if (note.noteNum == groupNote.noteNum) count++;
        }
        if (count == 0) {
          _noteListModel.add(note);
        }
      }
      for (int i = 0; i < _noteListModel.length; i++) {
        _noteCheck.add(false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    double _height = size.height;
    double _width = size.width;

    double _leadingL = _height * 0.02;
    double _bottomHeight = _height * 0.07;
    double _bottomIconWidth = _width * 0.05;

    double _titleSize = _height * 0.025;
    double _appBarSize = _width * 0.052;

    Color _color = Theme.of(context).primaryColor;
    Color _light = Theme.of(context).primaryColorLight;
    Color _hintGray = Color(0xffCCCCCC);

    Widget noNote = Center(child: Text('目前沒有任何筆記!'));
    Widget noteList;

    _submitShare(int noteNum) async {
      var submitWidget;
      _submitWidgetfunc() async {
        return Share(uid: uid, noteNum: noteNum, groupNum: groupNum);
      }

      submitWidget = await _submitWidgetfunc();
      if (await submitWidget.getIsError())
        return true;
      else
        return false;
    }

    int _noteCount() {
      int _noteCount = 0;
      for (int i = 0; i < _noteCheck.length; i++) {
        if (_noteCheck[i] == true) {
          _noteCount++;
        }
      }
      return _noteCount;
    }

    if (_noteListModel != null && _shareNoteList != null) {
      if (_noteListModel.length == 0) {
        noteList = noNote;
      } else {
        noteList = ListView.separated(
            itemCount: _noteListModel.length,
            itemBuilder: (BuildContext context, int index) {
              var note = _noteListModel[index];
              return ListTile(
                contentPadding: EdgeInsets.symmetric(
                    horizontal: _height * 0.03, vertical: _height * 0.008),
                title: Container(
                  margin: EdgeInsets.only(left: _height * 0.01),
                  child:
                      Text(note.title, style: TextStyle(fontSize: _titleSize)),
                ),
                trailing: CustomerCheckBox(
                  value: _noteCheck[index],
                  onTap: (value) {
                    setState(() {
                      if (value == true) {
                        if (_noteCount() < 1) {
                          _noteCheck[index] = value;
                          noteNum = note.noteNum;
                        }
                      } else {
                        _noteCheck[index] = value;
                      }
                    });
                    _buttonIsOnpressed();
                  },
                ),
                onTap: () {
                  setState(() {
                    if (_noteCheck[index] == false) {
                      if (_noteCount() < 1) {
                        _noteCheck[index] = true;
                        noteNum = note.noteNum;
                      }
                    } else {
                      _noteCheck[index] = false;
                    }
                  });
                  _buttonIsOnpressed();
                },
              );
            },
            separatorBuilder: (context, index) {
              return Divider(
                height: 1,
              );
            });
      }
    } else {
      noteList = Container(
          color: Colors.white,
          child: Center(child: CircularProgressIndicator()));
    }

    _onPressed() {
      var _onPressed;

      if (_isEnabled == true) {
        _onPressed = () async {
          if (await _submitShare(noteNum) != true) {
            Navigator.pop(context);
          }
        };
      }
      return _onPressed;
    }

    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).primaryColor,
          title: Text('選擇筆記', style: TextStyle(fontSize: _appBarSize)),
          leading: Container(
            margin: EdgeInsets.only(left: _leadingL),
            child: GestureDetector(
              child: Icon(Icons.chevron_left),
              onTap: () {
                Navigator.of(context).pop();
              },
            ),
          ),
        ),
        body: Container(color: Colors.white, child: noteList),
        bottomNavigationBar: Row(children: <Widget>[
          Expanded(
            // ignore: deprecated_member_use
            child: FlatButton(
              height: _bottomHeight,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(0)),
              child: Image.asset(
                'assets/images/cancel.png',
                width: _bottomIconWidth,
              ),
              color: _light,
              textColor: Colors.white,
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
          Expanded(
              // ignore: deprecated_member_use
              child: Builder(builder: (context) {
            // ignore: deprecated_member_use
            return FlatButton(
                disabledColor: _hintGray,
                height: _bottomHeight,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(0)),
                child: Image.asset(
                  'assets/images/confirm.png',
                  width: _bottomIconWidth,
                ),
                color: _color,
                textColor: Colors.white,
                onPressed: _onPressed());
          }))
        ]));
  }
}
