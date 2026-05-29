
import 'package:flutter/material.dart';
import 'package:sample_liveness_app/image_utils.dart';
import 'package:sample_liveness_app/models/camera_stream_payload.dart';
import 'package:sample_liveness_app/widgets/button.dart';

class KYCFacePage extends StatelessWidget {

  const KYCFacePage({
    super.key,
    required this.cameraCaptured
  });
  final CameraStreamPayload cameraCaptured;
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
        
              SizedBox(height: 50),

              FutureBuilder(
                future: ImageUtils.cameraImageToPng(cameraImage: cameraCaptured.cameraImage,rotation: cameraCaptured.rotation), 
                builder: (context, snapshot) {
                  if(snapshot.connectionState == ConnectionState.waiting){
                    return Container(
                      width: cameraCaptured.imageWidth.toDouble(),
                      height: cameraCaptured.imageHeight.toDouble(),
                      color: Colors.grey,
                    );
                  }
                  final bytes  = snapshot.data;
                  if(bytes == null){
                    return Text("Error convert face!.):");
                  }
                  
                  return Column(
                    children: [
                      SizedBox(
                        width: 300,
                        child: Image.memory(
                          bytes,
                          fit: BoxFit.contain,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text("${bytes.length /1000} kb"),
                      SizedBox(height: 40),
                      const Text("Done ✅",style: TextStyle(fontSize: 25)),
                    ],
                  );
                },
              ),
        
              SizedBox(height: 30),
              AppButton(
                onPressed: () {
                Navigator.popUntil(context, (route) => route.settings.name == '/');

                },
                label: "Back Home",
                radius: 0,
              ),
        
            ],
          ),
        ),
      ),
    );
  }
}