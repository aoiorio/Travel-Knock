import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Avatar extends StatelessWidget {
  const Avatar({
    super.key,
    required this.imageUrl,
    required this.onUpload,
  });

  final String? imageUrl;
  final void Function(String imageUrl) onUpload;

  @override
  Widget build(BuildContext context) {
    final supabase = Supabase.instance.client;

    void pickImage() async {
      final ImagePicker picker = ImagePicker();
      // Pick an image.
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
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
        SizedBox(
          width: 250,
          height: 350,
          child: imageUrl != null
              ? DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: NetworkImage(imageUrl!),
                      // fit: BoxFit.cover
                    ),
                  ),
                )
              : const DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xffEEEEEE),
                  ),
                ),
        ),
        Center(
          child: imageUrl != null
              ? IconButton(
                  // DONE create the database with supabase and connect to storage
                  onPressed: pickImage,
                  icon: const Icon(
                    Icons.wallpaper_outlined,
                    size: 40,
                  ),
                )
              : Column(
                  children: [
                    IconButton(
                      // DONE create the database with supabase and connect to storage
                      onPressed: pickImage,
                      icon: const Icon(
                        Icons.wallpaper_outlined,
                        size: 40,
                      ),
                    ),
                  ],
                ),
        ),
      ],
    );
  }
}
