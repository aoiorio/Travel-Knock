import 'package:flutter/material.dart';

// libraries import
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shimmer/shimmer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Header extends StatelessWidget {
  const Header({
    super.key,
    required this.headerUrl,
    required this.onUpload,
    required this.width,
    required this.height,
  });

  final String? headerUrl;
  final void Function(String imageUrl) onUpload;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    bool isLoading = false;
    final supabase = Supabase.instance.client;
    void pickImage() async {
      isLoading = true;
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
      final imagePath = '/$userId/header';
      await supabase.storage.from('profiles').uploadBinary(
            imagePath,
            imageBytes,
            fileOptions: FileOptions(
              upsert: true,
              contentType: 'image/$imageExtension',
            ),
          );
      String headerUrl =
          supabase.storage.from('profiles').getPublicUrl(imagePath);
      headerUrl = Uri.parse(headerUrl).replace(
          queryParameters: {'t': DateTime.now().toIso8601String()}).toString();
      onUpload(headerUrl);
      isLoading = false;
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: width, // 330
          height: height, // 200
          clipBehavior: Clip.antiAliasWithSaveLayer,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
          ),
          child: headerUrl != null
              ? CachedNetworkImage(
                  imageUrl: headerUrl!,
                  fit: BoxFit.cover,
                )
              : isLoading
                  ? Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(
                        width: 330,
                        height: 200,
                        decoration: const BoxDecoration(color: Colors.white),
                      ),
                    )
                  : CachedNetworkImage(
                      imageUrl:
                          'https://pmmgjywnzshfclavyeix.supabase.co/storage/v1/object/public/posts/6ab44cec-df53-4cc3-8c09-85907eb37815/IMG_8796.jpg',
                      fit: BoxFit.cover,
                    ),
        ),
        IconButton(
          onPressed: pickImage,
          icon: const Icon(
            Icons.wallpaper_outlined,
            size: 40,
          ),
        )
      ],
    );
  }
}
