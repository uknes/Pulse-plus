import 'package:flutter/material.dart';

class ImageOption {
  final String label;
  final String imagePath;

  ImageOption({required this.label, required this.imagePath});
}

class ImageSelectionDialog extends StatelessWidget {
  final String title;
  final List<ImageOption> options;
  final Function(String userType) onPressed; // Callback for selected option

  const ImageSelectionDialog({
    Key? key,
    required this.title,
    required this.options,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0), // Rounded corners
      ),
      child: Container(
        padding: EdgeInsets.all(16.0),
        width: MediaQuery.of(context).size.width * 0.8, // Dialog width
        child: Column(
          mainAxisSize: MainAxisSize.min, // Take only required space
          children: [
            Text(
              title,
              style: TextStyle(
                fontFamily: 'Nexa',
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF5EFF8B),
              ),
            ),
            SizedBox(height: 16), // Space between title and options
            GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.0,
                crossAxisSpacing: 10.0,
                mainAxisSpacing: 10.0,
              ),
              itemCount: options.length,
              shrinkWrap: true, // Allow grid to wrap content
              physics: NeverScrollableScrollPhysics(), // Disable scrolling
              itemBuilder: (context, index) {
                final option = options[index];
                return GestureDetector(
                  onTap: () {
                    onPressed(option.label); // Pass the selected label
                    Navigator.pop(context); // Close the dialog
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          option.imagePath,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover, // Ensure images fit well
                        ),
                        SizedBox(height: 8),
                        Text(option.label,
                          textAlign: TextAlign.center, // Center-align the text
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
