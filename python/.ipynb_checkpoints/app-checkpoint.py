from fastapi import FastAPI, UploadFile, File
from fastapi.middleware.cors import CORSMiddleware
import tensorflow as tf
from tensorflow.keras.models import load_model
from PIL import Image
import numpy as np
import io

app = FastAPI() #FastAPI application instance is created

# Add CORS middleware
app.add_middleware(
    CORSMiddleware, #Enable CORS middleware
    allow_origins=["*"],  # Allow requests from all origins (e.g., any website)
    allow_credentials=True,  # Allow credentials (e.g., cookies) in requests
    allow_methods=["*"],  # Allow all HTTP methods (GET, POST, etc.)
    allow_headers=["*"]  # Allow all headers in requests
)

# Load the model
# model = load_model("Flower_classification.h5")
model = load_model("flower_classifier.h5")


# Flower names 
flower_names = ['daisy', 'dandelion', 'iris', 'rose', 'sunflower']
@app.post("/predict/") #Created a POST endpoint for uploading and predicting flower images
async def predict(file: UploadFile = File(...)): #defined async function to handle uploaded fiels
    # Read the image file
    image_bytes = await file.read()
    
    # Open and preprocess the image
    image = Image.open(io.BytesIO(image_bytes)).convert("RGB") #opens the image from bytes and convert it to RGB
    image = image.resize((224, 224))  # Resized the image to match incoming input images
    image_array = np.array(image) / 255.0 #converted image to numpy array
    
    # Add batch dimension
    processed_image = np.expand_dims(image_array, axis=0) 
    
    # Predict
    predictions = model.predict(processed_image) #run the model to get prediction 
    result = tf.nn.softmax(predictions[0]) #applied softmax to convert raw scores to probability
    
    # Get the predicted class and confidence
    predicted_class_index = np.argmax(result) #stores the class with higesht accuracy
    confidence = np.max(result) * 100 
    
    return {
        "prediction": predictions.tolist(),
        "flower_name": flower_names[predicted_class_index],
        "confidence": float(confidence)
    }