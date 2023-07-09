import 'package:flutter/material.dart';

class Feature {
  final String image, title;
  final int id;

  Feature({required this.image, required this.title, required this.id});

}

List<Feature> features = [
  Feature(
    id: 1,
    title: "English",
    image: "assets/english.jpg",
  ),
  Feature(
    id: 2,
    title: "Biology",
    image: "assets/biology.jpg",
  ),
  Feature(
    id: 3,
    title: "Chemistry",
    image: "assets/sciencechemistry.jpg",
  ),
  Feature(
    id: 4,
    title: "Physics",
    image: "assets/sciencephysics.jpg",
  ),
  Feature(
    id: 5,
    title: "Documentary",
    image: "assets/documentory.jpg",
  ),
  Feature(
    id: 6,
    title: "Fiction",
    image: "assets/fiction.jpg",
  ),
  Feature(
    id: 7,
    title: "Children Book",
    image: "assets/children book.jpg",
  ),
  Feature(
    id: 8,
    title: "Cook Book",
    image: "assets/cook book.jpg",
  )
];