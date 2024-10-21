import 'package:drinks/view/screens/home_page.dart';
import 'package:drinks/view/screens/monthly_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_branch_sdk/flutter_branch_sdk.dart';
import 'package:share_plus/share_plus.dart';

class CustomBottumNavigationBar extends StatefulWidget {
  const CustomBottumNavigationBar({super.key});

  @override
  State<CustomBottumNavigationBar> createState() =>
      _CustomBottumNavigationBarState();
}

class _CustomBottumNavigationBarState extends State<CustomBottumNavigationBar> {
  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: Colors.grey[800],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MonthlyPage(),
                  ));
            },
          ),
          IconButton(
            icon: const Icon(Icons.home, color: Colors.white),
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => const HomePage(),
                ),
                (route) => false,
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: () {
              shareContent();
            },
          ),
        ],
      ),
    );
  }

  void shareContent() async {
    // Create Branch Universal Object
    BranchUniversalObject buo = BranchUniversalObject(
      canonicalIdentifier: 'flutter/branch',
      title: 'My Flutter App',
      contentDescription: 'Check out this cool content!',
      publiclyIndex: true,
      locallyIndex: true,
    );

    // Create link properties
    BranchLinkProperties linkProperties = BranchLinkProperties(
      channel: 'app',
      feature: 'share',
      campaign: 'flutter_share',
    );

    // Add any custom parameters if needed
    linkProperties.addControlParam('\$desktop_url', 'https://myapp.com');

    // Generate short URL
    BranchResponse response = await FlutterBranchSdk.getShortUrl(
      buo: buo, // Correct parameter name
      linkProperties: linkProperties,
    );

    if (response.success) {
      final generatedLink = response.result;

      // Share the generated link
      Share.share(generatedLink, subject: 'Check this out!');
    } else {
      print('Error: ${response.errorMessage}');
    }
  }
}
