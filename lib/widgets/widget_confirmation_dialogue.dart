import 'package:flutter/material.dart';

class ConfirmationDialogue {
  static void show(
    BuildContext context, {
      required String title,
      required String message,
      String confirmText = "Confirmer",
      String canceltext = "Annuler",
      Color confirmColor = Colors.red,
      VoidCallback? onConfirm,
      VoidCallback? onCancel,
    }
  ) {
    showDialog(
      context: context, 
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        backgroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: (){
              Navigator.pop(context);
              if (onCancel != null) onCancel();
            }, 
            child: Text(canceltext),
            ),
            TextButton(
              onPressed: (){
                Navigator.pop(context);
                if (onConfirm != null) onConfirm();
              }, 
              child: Text(
                confirmText,
                style: TextStyle(color: confirmColor),
              ),
            )
        ],

      )
      );
  }
}