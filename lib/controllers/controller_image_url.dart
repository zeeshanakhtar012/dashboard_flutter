import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';

/// Controller to fetch and manage image URLs from Firebase Storage
class ControllerImagesUrl extends GetxController {
  // Reactive variable to store a single image URL
  var imageUrl = ''.obs;

  // Reactive variable to handle loading state
  var isLoading = false.obs;

  // Reactive variable for error messages
  var errorMessage = ''.obs;

  /// Function to fetch the admin's single image URL from a specific collection (folder) in Firebase Storage
  Future<void> fetchAdminImage(String collectionPath) async {
    try {
      // Start loading
      isLoading.value = true;
      errorMessage.value = '';

      // Get reference to the collection
      Reference collectionRef = FirebaseStorage.instance.ref().child(collectionPath);

      // Fetch list of items in the collection
      ListResult result = await collectionRef.listAll();

      // Assuming the first item is the admin's image
      if (result.items.isNotEmpty) {
        imageUrl.value = await result.items[0].getDownloadURL();
      } else {
        errorMessage.value = "No images found in $collectionPath.";
      }
    } catch (e) {
      errorMessage.value = "Error fetching admin image from $collectionPath: $e";
      print(errorMessage.value);
    } finally {
      // Stop loading
      isLoading.value = false;
    }
  }

  /// Function to fetch all image URLs from a specific collection (folder) in Firebase Storage
  Future<void> fetchMultipleImagesFromCollection(String collectionPath) async {
    try {
      // Start loading
      isLoading.value = true;
      errorMessage.value = '';

      // Get reference to the collection
      Reference collectionRef = FirebaseStorage.instance.ref().child(collectionPath);

      // Fetch list of items in the collection
      ListResult result = await collectionRef.listAll();

      // Assuming you want to fetch URLs of all items
      List<String> urls = [];
      for (var item in result.items) {
        String url = await item.getDownloadURL();
        urls.add(url);
      }

      // Handle the list of URLs as needed
      // For example, you could return the list or store it in a reactive variable if necessary
      print(urls); // Just for demonstration
    } catch (e) {
      errorMessage.value = "Error fetching multiple images from $collectionPath: $e";
      print(errorMessage.value);
    } finally {
      // Stop loading
      isLoading.value = false;
    }
  }
}
