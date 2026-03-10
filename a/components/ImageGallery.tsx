import React, { useState, useEffect } from 'react';
import { View, Text, Image, TouchableOpacity, Alert, ActivityIndicator, Modal, Dimensions } from 'react-native';
import * as ImagePicker from 'expo-image-picker';
import * as ImageManipulator from 'expo-image-manipulator';

interface ImageGalleryProps {
  initialImages?: string[];
  isPublicView?: boolean;
  userId?: string; // 🚀 REQUIRED TO SAVE TO DB
}

const { width: SCREEN_WIDTH, height: SCREEN_HEIGHT } = Dimensions.get('window');

export const ImageGallery = ({ initialImages = [], isPublicView = false, userId }: ImageGalleryProps) => {
  const [images, setImages] = useState<string[]>(initialImages);
  const [currentPage, setCurrentPage] = useState(1);
  const [isUploading, setIsUploading] = useState(false);
  
  // State for Fullscreen Viewer
  const [selectedImage, setSelectedImage] = useState<string | null>(null);

  // Sync state if initialImages prop updates from Parent
  useEffect(() => {
    if (initialImages.length > 0) {
      setImages(initialImages);
    }
  }, [initialImages]);
  
  // 🚀 PAGINATION SET FOR 6 MAX IMAGES
  const ITEMS_PER_PAGE = isPublicView ? 6 : 5; 
  const totalPages = Math.ceil((isPublicView ? images.length : images.length + 1) / ITEMS_PER_PAGE) || 1;
  const startIndex = (currentPage - 1) * ITEMS_PER_PAGE;
  const currentImages = images.slice(startIndex, startIndex + ITEMS_PER_PAGE);

  const handleUploadPhoto = async () => {
    if (isPublicView) return;

    // 🚀 STRICT MAX LIMIT: 6 🚀
    if (images.length >= 6) {
      Alert.alert("Limit Reached", "You can only upload a maximum of 6 photos.");
      return;
    }

    const permissionResult = await ImagePicker.requestMediaLibraryPermissionsAsync();
    if (permissionResult.granted === false) {
      Alert.alert("Permission Required", "Allow access to photos to upload.");
      return;
    }

    const result = await ImagePicker.launchImageLibraryAsync({
      mediaTypes: ['images'],
      allowsEditing: true,
      aspect: [4, 4], 
      quality: 1, 
    });

    if (!result.canceled && result.assets && result.assets.length > 0) {
      const originalUri = result.assets[0].uri;
      setIsUploading(true);

      try {
        console.log("1. Manipulating: Converting to WEBP...");
        const manipResult = await ImageManipulator.manipulateAsync(
          originalUri,
          [{ resize: { width: 800 } }],
          { compress: 0.7, format: ImageManipulator.SaveFormat.WEBP }
        );

        console.log("2. Fetching upload ticket from 3001...");
        const response = await fetch('http://10.0.2.2:3001/api/get-upload-url');
        const { uploadUrl, publicUrl } = await response.json();

        if (!uploadUrl) throw new Error("Server failed to provide upload link.");

        console.log("3. Sending to Cloudflare...");
        const imageResponse = await fetch(manipResult.uri);
        const blob = await imageResponse.blob();

        const uploadRes = await fetch(uploadUrl, {
          method: 'PUT',
          body: blob,
          headers: { 'Content-Type': 'image/webp' },
        });

        if (uploadRes.ok) {
          console.log("4. SUCCESS! Saving to Database...");
          
          // Update local view
          const newImages = [publicUrl, ...images];
          setImages(newImages);
          
          // 🚀 PERSIST TO DATABASE 🚀
          if (userId) {
            await fetch('http://10.0.2.2:3001/api/gallery/add', {
              method: 'POST',
              headers: { 'Content-Type': 'application/json' },
              body: JSON.stringify({ userId: userId, imageUrl: publicUrl })
            });
          }

          Alert.alert("Saved!", "Photo added to your gallery permanently.");
        } else {
          throw new Error("Cloudflare rejected file.");
        }
      } catch (error: any) {
        console.error("Upload Error:", error);
        Alert.alert("Upload Failed", "Could not save photo to cloud.");
      } finally {
        setIsUploading(false);
      }
    }
  };

  const handleImagePress = (imgUri: string) => {
    setSelectedImage(imgUri);
  };

  const handleImageLongPress = (index: number) => {
    if (isPublicView) return;

    Alert.alert(
      "Delete Photo", 
      "Remove this photo permanently?",
      [
        { text: "Cancel", style: "cancel" },
        { 
          text: "Delete", 
          style: "destructive", 
          onPress: async () => {
            const actualIndex = startIndex + index;
            const imgToRemove = images[actualIndex];
            
            // Remove locally
            setImages(prev => prev.filter((_, i) => i !== actualIndex));

            // 🚀 REMOVE FROM DATABASE 🚀
            if (userId) {
              try {
                await fetch('http://10.0.2.2:3001/api/gallery/remove', {
                  method: 'POST',
                  headers: { 'Content-Type': 'application/json' },
                  body: JSON.stringify({ userId: userId, imageUrl: imgToRemove })
                });
              } catch (e) {
                console.error("DB Delete Error", e);
              }
            }
          } 
        }
      ]
    );
  };

  return (
    <View className="bg-white rounded-2xl shadow-sm border border-gray-100 p-4 mb-4">
      <Text className="text-xl font-black text-gray-800 mb-4">
        {isPublicView ? `📸 Gallery (${images.length})` : `📸 My Gallery (${images.length}/6)`}
      </Text>
      
      <View className="flex-row flex-wrap justify-start gap-2 mb-2">
        {!isPublicView && currentPage === 1 && images.length < 6 && (
          <TouchableOpacity 
            onPress={handleUploadPhoto}
            disabled={isUploading}
            className="w-[31%] aspect-square rounded-xl overflow-hidden border-2 border-dashed border-green-400 bg-green-50 items-center justify-center"
          >
            {isUploading ? (
              <ActivityIndicator color="#4CAF50" size="large" />
            ) : (
              <>
                <Text className="text-3xl">➕</Text>
                <Text className="text-[10px] font-bold text-green-600 mt-1 uppercase tracking-wider">Upload</Text>
              </>
            )}
          </TouchableOpacity>
        )}

        {currentImages.map((imgUri, index) => (
          <TouchableOpacity 
            key={index}
            onPress={() => handleImagePress(imgUri)} 
            onLongPress={() => handleImageLongPress(index)} 
            className="w-[31%] aspect-square rounded-xl overflow-hidden border border-gray-200 shadow-sm"
          >
            <Image source={{ uri: imgUri }} className="w-full h-full bg-gray-200" />
          </TouchableOpacity>
        ))}

        {isPublicView && images.length === 0 && (
          <Text className="text-gray-400 text-center py-4 font-bold w-full">No photos yet.</Text>
        )}
      </View>

      {/* Pagination */}
      {images.length > (isPublicView ? ITEMS_PER_PAGE : ITEMS_PER_PAGE - 1) && (
        <View className="flex-row justify-between items-center mt-2 border-t border-gray-100 pt-3">
          <TouchableOpacity 
            onPress={() => setCurrentPage(prev => Math.max(prev - 1, 1))} 
            className={`p-2 rounded-lg min-w-[80px] items-center ${currentPage === 1 ? 'bg-gray-300' : 'bg-green-500'}`}
            disabled={currentPage === 1}
          >
            <Text className="text-white font-bold text-xs">Prev</Text>
          </TouchableOpacity>
          <Text className="text-gray-600 font-bold text-xs">{currentPage} / {totalPages}</Text>
          <TouchableOpacity 
            onPress={() => setCurrentPage(prev => Math.min(prev + 1, totalPages))} 
            className={`p-2 rounded-lg min-w-[80px] items-center ${currentPage === totalPages ? 'bg-gray-300' : 'bg-green-500'}`}
            disabled={currentPage === totalPages}
          >
            <Text className="text-white font-bold text-xs">Next</Text>
          </TouchableOpacity>
        </View>
      )}

      {/* 🚀 FIXED MODAL: NO MORE BLACK RECTANGLES 🚀 */}
      <Modal visible={!!selectedImage} transparent={true} animationType="fade">
        <View style={{ flex: 1, backgroundColor: 'rgba(0,0,0,0.95)', justifyContent: 'center', alignItems: 'center' }}>
          <TouchableOpacity 
            style={{ position: 'absolute', top: 50, right: 20, zIndex: 100, backgroundColor: 'white', borderRadius: 20, padding: 8 }}
            onPress={() => setSelectedImage(null)}
          >
            <Text style={{ fontWeight: 'bold', color: 'black' }}>✕ CLOSE</Text>
          </TouchableOpacity>
          
          {selectedImage && (
            <Image 
              source={{ uri: selectedImage }} 
              style={{ width: SCREEN_WIDTH, height: SCREEN_HEIGHT * 0.7 }} 
              resizeMode="contain" 
            />
          )}
        </View>
      </Modal>
    </View>
  );
};