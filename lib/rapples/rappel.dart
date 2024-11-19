import 'package:carhabty/rapples/DetailRappelPage.dart';
import 'package:carhabty/rapples/EditRappelPage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/message_view_model.dart';
import '../models/rappel.dart';
import 'package:intl/intl.dart';

class MessagePage extends StatelessWidget {

 void _editRappel(BuildContext context, int id) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditRappelPage(rappelId: id),
      ),
    ).then((_) {
       Provider.of<MessageViewModel>(context, listen: false).fetchRappels();
     // Rafraîchir la liste après modification
    });
  }

  void _showDetails(BuildContext context, int id) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RappelDetailPage(rappelId: id),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MessageViewModel()..fetchRappels(),
      child: Scaffold(
        body: Consumer<MessageViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (viewModel.rappels.isEmpty) {
              return const Center(child: Text("Aucun rappel disponible"));
            }

            return ListView.builder(
              itemCount: viewModel.rappels.length,
              itemBuilder: (context, index) {
                final Rappel rappel = viewModel.rappels[index];
                final typeIcon =
                    rappel.type == 'depense' ? Icons.attach_money : Icons.build;
                    print(rappel.type);

                // Conversion de la date (String -> DateTime)
                DateTime rappelDate = DateTime.parse(rappel.date);

                // Calcul de la différence entre les dates
                DateTime now = DateTime.now();
                int daysDifference = rappelDate.difference(now).inDays;
                bool isPast = daysDifference < 0;
                

                // Formatage de la date
                String formattedDate =
                    DateFormat('yyyy-MM-dd').format(rappelDate);
                String daysInfo = isPast
                    ? "Il y a ${daysDifference.abs()} jours"
                    : "Reste $daysDifference jours";

                return Card(
                  margin:
                      const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  child: ListTile(
                    leading: Icon(typeIcon, color: Colors.blue),
                    title: const Text("Rappel"),
                    subtitle: Text(
                      "Date: $formattedDate\n$daysInfo",
                      style:
                          TextStyle(color: isPast ? Colors.red : Colors.green),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                         IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () => _editRappel(context, rappel.id),
                            ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            viewModel.deleteRappel(rappel.id);
                          },
                        ),
                        IconButton(
                              icon: Icon(Icons.info),
                              onPressed: () => _showDetails(context, rappel.id),
                            ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
