

import 'package:flutter/material.dart';
import 'package:sample_liveness_app/models/model_type.dart';

class ResultView extends StatelessWidget {
  const ResultView({
    super.key,
    required this.fields,
    required this.dims,
    required this.w,
  });

  final double w;
  final Map<String, String> fields;
  final Map<ModelType, int?> dims;

  @override
  Widget build(BuildContext context) {
    return _buildResponse();
  }


  Widget _buildResponse() {
    int total = dims.values
      .whereType<int>() 
      .fold(0, (sum, val) => sum + val);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        
        ...fields.entries.map(
          (e) => _buildResultRow(
            e.key,
            e.value
          )
        ),

        ...ModelType.values.map(
          (e) => _buildResultRow(
            "${e.label} :",
            dims[e] == null ? "N/A" : "${dims[e]}ms"
          )
        ),
        
        _buildResultRow(
          "Total Duration : ",
          "$total ms"
        )
      ],
    );
  }

  Widget _buildResultRow(String key,String value){
    final s = w > 380 ? 12.0 : 10.0;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          key,
          style: TextStyle(
            fontSize: s,
            color: Colors.white
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: s,
            color: const Color.fromARGB(255, 34, 157, 38)
          ),
        )
      ],
    );
  }
}