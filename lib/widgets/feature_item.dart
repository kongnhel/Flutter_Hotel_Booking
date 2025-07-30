import 'package:flutter/material.dart';
import 'package:hotel_booking/models/room_model.dart';
import 'package:hotel_booking/theme/color.dart';
import 'package:hotel_booking/widgets/custom_image.dart';
import 'package:hotel_booking/widgets/favorite_box.dart';

class FeatureItem extends StatelessWidget {
  const FeatureItem({
    Key? key,
    required this.data,
    required this.roomTypeName,
    this.width = 280,
    this.onTap,
    this.onTapFavorite,
  }) : super(key: key);

  final String roomTypeName;
  final Room data;
  final double width;
  final GestureTapCallback? onTapFavorite;
  final GestureTapCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            width: width,
            padding: const EdgeInsets.all(10),
            margin: const EdgeInsets.symmetric(vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColor.shadowColor.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 1,
                  offset: const Offset(1, 1),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildImage(data),
                Padding(
                  padding: const EdgeInsets.fromLTRB(5, 10, 5, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildName(data),
                      const SizedBox(height: 5),
                      _buildInfo(data),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // បន្ថែម Badge ប្រសិនបើបានកក់
          if (data.isBooked)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black45,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Center(
                  child: Text(
                    "បានកក់", // "Booked" in Khmer
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildName(Room room) {
    return Text(
      data.name,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        fontSize: 18,
        color: AppColor.textColor,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildInfo(Room room) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.category_outlined,
                  color: AppColor.labelColor,
                  size: 13,
                ),
                const SizedBox(width: 2),
                Text(
                  roomTypeName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: AppColor.labelColor, fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 3),
            Row(
              children: [
                Icon(Icons.place, color: AppColor.labelColor, size: 13),
                const SizedBox(width: 2),
                Text(
                  data.location,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: AppColor.labelColor, fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '\$${data.price}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AppColor.primary,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        FavoriteBox(
          size: 16,
          onTap: onTapFavorite,
          isFavorited: data.isFavorited,
        ),
      ],
    );
  }

  Widget _buildImage(Room room) {
    return CustomImage(
      data.image,
      width: double.infinity,
      height: 200,
      radius: 15,
    );
  }
}
