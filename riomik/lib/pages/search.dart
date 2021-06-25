import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:riomik/models/user.dart';
import 'package:riomik/pages/activity_feed.dart';
import 'package:riomik/pages/home.dart';
import 'package:riomik/widgets/progress.dart';

class Search extends StatefulWidget {
  static const  String id = 'search_screen';
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> with
AutomaticKeepAliveClientMixin<Search>
{
  TextEditingController searchController = TextEditingController();
  Future<QuerySnapshot> searchFutureResult;
  handleSearch(String query) {
    Future<QuerySnapshot> users = userRef
        .where('displayName', isGreaterThanOrEqualTo: query)
        .getDocuments();
    setState(() {
      searchFutureResult = users;
    });
  }
  clearSearch() {
    searchController.clear();
  }

  AppBar buildSearchResult() {
    return AppBar(
      backgroundColor: Colors.red,
      title: TextFormField(
        decoration: InputDecoration(
          hintText: 'Search For Users',

          filled: true,
          prefixIcon: Icon(
            Icons.account_box,
            color: Colors.white,
            size: 30.0,
          ),
          suffixIcon: IconButton(
            icon: Icon(Icons.clear, color: Colors.white,),
            onPressed: clearSearch,
          ),
        ),
        onFieldSubmitted: handleSearch,
      ),
    );
  }

  Container buildNoContent() {
    final Orientation orientation = MediaQuery.of(context).orientation;
    return Container(
      child: Center(
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            Text(
              'Find User',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 50.0,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  buildSearchContent() {
    return FutureBuilder(
      future: searchFutureResult,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }
        List<UserResult> searchResult = [];
        snapshot.data.documents.forEach((doc) {
          User user = User.fromDocument(doc);
          UserResult searchResults = UserResult(user);
          searchResult.add(searchResults);
        });
        return ListView(
          children: searchResult,
        );
      },
    );
  }
bool get wantKeepAlive=> true;
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: Colors.pinkAccent,
      appBar: buildSearchResult(),
      body:
      searchFutureResult == null ? buildNoContent() : buildSearchContent(),
    );
  }
}

class UserResult extends StatelessWidget {
  final User user;
  UserResult(this.user);
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          GestureDetector(
            onTap: () => showProfile(context, profileId: user.id),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.grey,
                backgroundImage: CachedNetworkImageProvider(user.photoUrl),
              ),
              title: Text(
                user.displayName,
                style:
                TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                user.username,
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
          Divider(),
        ],
      ),
    );
  }
}
