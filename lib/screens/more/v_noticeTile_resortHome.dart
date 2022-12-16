import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NoticeTile_resortHome extends StatefulWidget {
  const NoticeTile_resortHome({Key? key}) : super(key: key);

  @override
  State<NoticeTile_resortHome> createState() => _NoticeTile_resortHomeState();
}

class _NoticeTile_resortHomeState extends State<NoticeTile_resortHome> {


  @override
  void setState(VoidCallback fn) {
    // TODO: implement setState
    setState(fn);
  }

  @override
  Widget build(BuildContext context) {

    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('notice')
          .orderBy('timeStamp', descending: true)
          .snapshots(),
      builder: (context,
          AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
        if (!snapshot.hasData) {
          return Container(
            color: Colors.white,
          );
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        final noticeDocs = snapshot.data!.docs;
        Size _size = MediaQuery.of(context).size;

        return CarouselSlider.builder(
          options: CarouselOptions(
              height: 20,
              viewportFraction: 1,
              reverse: true,
              enableInfiniteScroll: false,
              autoPlay: true,
              autoPlayInterval: Duration(seconds: 4)),
          itemCount: noticeDocs.length,
          itemBuilder: (context, index, pageViewIndex) {
            return Padding(
              padding: const EdgeInsets.only(left: 18, right: 18),
              child: Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      constraints: BoxConstraints(maxWidth: _size.width - 100),
                      child: Text(
                        noticeDocs[index].get('noticeTitle'),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Image.asset('assets/imgs/icons/icon_arrow_g.png',
                      height: 24,
                      width: 24,
                    )
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
