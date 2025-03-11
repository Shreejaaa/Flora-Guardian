import 'package:flutter/material.dart';

class OnlineFlowersList extends StatelessWidget {
  final String flowerImage;
  final String commonName;
  final String scientificName;
  final VoidCallback onListTap;
  final VoidCallback onAddTap;

  const OnlineFlowersList({
    super.key,
    required this.flowerImage,
    required this.commonName,
    required this.onListTap,
    required this.onAddTap, required this.scientificName,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onListTap,
      child: Container(
        height: 100,
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 8),

        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: 80,
              width: 80,
              decoration: BoxDecoration(
                color: Colors.black,
                shape: BoxShape.circle,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(80),
                child: Image.network(
                  flowerImage.isNotEmpty
                      ? flowerImage
                      : 'https://via.placeholder.com/150?text=No+Image',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[300],
                      child: const Icon(
                        Icons.image_not_supported,
                        color: Colors.grey,
                        size: 40,
                      ),
                    );
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value:
                            loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    commonName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    scientificName,
                    style: const TextStyle(fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            TextButton(
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
              onPressed: onAddTap,
              child: const Row(
                mainAxisSize: MainAxisSize.min,

                children: [
                  Text("Add"),
                  SizedBox(width: 4),
                  Icon(Icons.add, size: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
