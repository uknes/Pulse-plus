import 'package:flutter/material.dart';

class ImageOption {
  final String label;
  final String imagePath;

  ImageOption({required this.label, required this.imagePath});
}

class ContentSelectionDialog extends StatefulWidget {
  final String title;
  final Function(String userType, String contentType) onPressed;

  const ContentSelectionDialog({
    Key? key,
    required this.title,
    required this.onPressed,
  }) : super(key: key);

  @override
  _ContentSelectionDialogState createState() => _ContentSelectionDialogState();
}

class _ContentSelectionDialogState extends State<ContentSelectionDialog> {
  String? userType;

  final List<ImageOption> userTypeOptions = [
    ImageOption(label: 'Doctor', imagePath: 'assets/images/doctor.png'),
    ImageOption(label: 'Regular User', imagePath: 'assets/images/regular_user.png'),
  ];

  final List<ImageOption> contentTypeOptions = [
    ImageOption(label: 'Adult', imagePath: 'assets/images/adult.png'),
    ImageOption(label: 'Children', imagePath: 'assets/images/children.png'),
  ];

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Container(
        padding: EdgeInsets.all(16.0),
        width: MediaQuery.of(context).size.width * 0.8,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.title,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            if (userType == null) ...[
              Text("Select User Type"),
              SizedBox(height: 16),
              GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.0,
                  crossAxisSpacing: 10.0,
                  mainAxisSpacing: 10.0,
                ),
                itemCount: userTypeOptions.length,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  final option = userTypeOptions[index];
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        userType = option.label; // Set user type
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(option.imagePath, width: 80, height: 80),
                          SizedBox(height: 8),
                          Text(option.label),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ] else ...[
              Text("Select Content Type for $userType"),
              SizedBox(height: 16),
              GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.0,
                  crossAxisSpacing: 10.0,
                  mainAxisSpacing: 10.0,
                ),
                itemCount: contentTypeOptions.length,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  final option = contentTypeOptions[index];
                  return GestureDetector(
                    onTap: () {
                      widget.onPressed(userType!, option.label); // Call onPressed with both selections
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
                          Image.asset(option.imagePath, width: 80, height: 80),
                          SizedBox(height: 8),
                          Text(option.label),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Usage in your main code

