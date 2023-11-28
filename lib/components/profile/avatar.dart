import 'package:flutter/material.dart';

// libraries import
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shimmer/shimmer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Avatar extends StatelessWidget {
  const Avatar({
    super.key,
    required this.imageUrl,
    required this.onUpload,
    required this.height,
    required this.width,
  });

  final String? imageUrl;
  final void Function(String imageUrl) onUpload;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final supabase = Supabase.instance.client;

    void pickImage() async {
      final ImagePicker picker = ImagePicker();
      // Pick an image.
      final XFile? image =
          await picker.pickImage(source: ImageSource.gallery, imageQuality: 0);
      if (image == null) {
        return;
      }
      final imageExtension = image.path.split('.').last.toLowerCase();
      final imageBytes = await image.readAsBytes();
      final userId = supabase.auth.currentUser!.id;
      final imagePath = '/$userId/profile';
      await supabase.storage.from('profiles').uploadBinary(
            imagePath,
            imageBytes,
            fileOptions: FileOptions(
              upsert: true,
              contentType: 'image/$imageExtension',
            ),
          );
      String imageUrl =
          supabase.storage.from('profiles').getPublicUrl(imagePath);
      imageUrl = Uri.parse(imageUrl).replace(
          queryParameters: {'t': DateTime.now().toIso8601String()}).toString();
      onUpload(imageUrl);
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        GestureDetector(
          onTap: pickImage,
          child: Container(
            width: width, // 250
            height: height,
            decoration: const BoxDecoration(shape: BoxShape.circle), // 350
            clipBehavior: Clip.antiAliasWithSaveLayer,
            child: imageUrl != null
                ? CachedNetworkImage(
                    imageUrl: imageUrl!,
                    fit: BoxFit.cover,
                  )
                : Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(
                      decoration: const BoxDecoration(color: Colors.white),
                    ),
                  ),
          ),
        ),
        imageUrl != null
            ? IconButton(
                // DONE create the database with supabase and connect to storage
                onPressed: pickImage,
                icon: const Icon(
                  Icons.wallpaper_outlined,
                  size: 40,
                ),
              )
            : IconButton(
                // DONE create the database with supabase and connect to storage
                onPressed: pickImage,
                icon: const Icon(
                  Icons.wallpaper_outlined,
                  size: 40,
                ),
              ),
      ],
    );
  }
}
