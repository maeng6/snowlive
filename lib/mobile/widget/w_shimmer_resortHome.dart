import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';


Widget loading_resortHome_scoreBox(containerHeight) {
  return Container(
    height: containerHeight, // Set fixed height for the loading widget
    decoration: BoxDecoration(
      color: Color(0xFFF5F2F7),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Row(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 35, top: 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Shimmer.fromColors(
                          baseColor: Colors.grey[300]!,
                          highlightColor: Colors.grey[100]!,
                          period: Duration(seconds: 1), // 애니메이션 속도를 빠르게 설정
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(6.0),
                            child: Container(
                              width: 50,
                              height: 13,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(height: 10,),
                        Shimmer.fromColors(
                          baseColor: Colors.grey[300]!,
                          highlightColor: Colors.grey[100]!,
                          period: Duration(seconds: 1), // 애니메이션 속도를 빠르게 설정
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(6.0),
                            child: Container(
                              width: 30,
                              height: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 30,),
                  Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Shimmer.fromColors(
                          baseColor: Colors.grey[300]!,
                          highlightColor: Colors.grey[100]!,
                          period: Duration(seconds: 1), // 애니메이션 속도를 빠르게 설정
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(6.0),
                            child: Container(
                              width: 50,
                              height: 13,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(height: 10,),
                        Shimmer.fromColors(
                          baseColor: Colors.grey[300]!,
                          highlightColor: Colors.grey[100]!,
                          period: Duration(seconds: 1), // 애니메이션 속도를 빠르게 설정
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(6.0),
                            child: Container(
                              width: 30,
                              height: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 30,),
                  Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    period: Duration(seconds: 1), // 애니메이션 속도를 빠르게 설정
                    child: Padding(
                      padding: const EdgeInsets.only(top: 7),
                      child: GestureDetector(
                        onTap: () {
                          // Add your share functionality here
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              Text(
                                '공유하기',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(width: 10,),
                              Image.asset(
                                'assets/imgs/icons/icon_arrow_round_black.png',
                                fit: BoxFit.cover,
                                width: 18,
                                height: 18,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  );
}