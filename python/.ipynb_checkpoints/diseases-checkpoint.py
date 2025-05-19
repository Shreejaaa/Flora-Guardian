 
from fastapi import FastAPI, UploadFile, File
from fastapi.middleware.cors import CORSMiddleware
import tensorflow as tf
from tensorflow.keras.models import load_model
from PIL import Image, UnidentifiedImageError
import numpy as np
import io
import traceback
#importing all the necessary libraries

app = FastAPI() #fastapi object is instantiated 

# Add CORS middleware to allow all the requests from origins, methods and headers
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"]
)

# Load the disease classification model
try:
    model = load_model("disease_recognition.h5")
    print("Model loaded successfully")
    print(model.summary())  # Print model architecture to confirm input shape
except Exception as e:
    print("Failed to load model:", str(e))

# Disease and healthy leaf classes
class_names = {
    0: 'Apple___Apple_scab',
    1: 'Apple___Black_rot',
    2: 'Apple___Cedar_apple_rust',
    3: 'Apple___healthy',
    4: 'Corn_(maize)___Cercospora_leaf_spot Gray_leaf_spot',
    5: 'Corn_(maize)___Common_rust_',
    6: 'Corn_(maize)___Northern_Leaf_Blight',
    7: 'Corn_(maize)___healthy',
    8: 'Grape___Black_rot',
    9: 'Grape___Esca_(Black_Measles)',
    10: 'Grape___Leaf_blight_(Isariopsis_Leaf_Spot)',
    11: 'Grape___healthy',
    12: 'Potato___Early_blight',
    13: 'Potato___Late_blight',
    14: 'Potato___healthy',
    15: 'Tomato___Bacterial_spot',
    16: 'Tomato___Leaf_Mold',
    17: 'Tomato___Septoria_leaf_spot',
    18: 'Tomato___healthy'
}

@app.post("/predict-disease/") #api end point is created 
async def predict_disease(file: UploadFile = File(...)): 
    try:
        # Read the image file
        image_bytes = await file.read()
        print("Image bytes read:", len(image_bytes))
        
        # Open and preprocess the image
        try:
            image = Image.open(io.BytesIO(image_bytes)).convert("RGB")
        except UnidentifiedImageError:
            return {"success": False, "error": "Invalid or corrupted image file"}
        
        image = image.resize((224, 224))  
        image_array = np.array(image) / 255.0
        print("Image preprocessed:", image_array.shape)
        
        # Add batch dimension
        processed_image = np.expand_dims(image_array, axis=0)
        print("Processed image shape:", processed_image.shape)
        
        # Predict
        predictions = model.predict(processed_image)
        print("Predictions:", predictions)
        result = tf.nn.softmax(predictions[0])
        
        # Get the predicted class and confidence
        predicted_class_index = np.argmax(result)
        confidence = np.max(result) * 100
        predicted_class_name = class_names[predicted_class_index]
        
        # Split into plant type and condition (healthy/disease)
        plant_type, condition = predicted_class_name.split('___')
        
        return {
            "disease_name": predicted_class_name,
            "plant_type": plant_type,
            "condition": condition,
            "confidence": float(confidence)
        }
    except Exception as e:
        print("Error occurred:", str(e))
        return {
            "success": False,
            "error": str(e),
            "traceback": traceback.format_exc()
        }