import 'package:flutter/material.dart';

class Science {
  final String image, title;
  final int id;

  Science({required this.image, required this.title, required this.id});

}

List<Science> sciences = [
  Science(
    id: 1,
    title: "Biology",
    image: "assets/sciencebiology.jpg",
  ),
  Science(
    id: 2,
    title: "Chemistry",
    image: "assets/sciencechemistry.jpg",
  ),
  Science(
    id: 3,
    title: "Physics",
    image: "assets/sciencephysics.jpg",
  ),
];