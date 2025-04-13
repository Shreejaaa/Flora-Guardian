from fastapi import FastAPI, UploadFile, File
from fastapi.middleware.cors import CORSMiddleware
import tensorflow as tf
from tensorflow.keras.models import load_model
from PIL import Image
import numpy as np
import io

app = FastAPI()

# Add CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"]
)

# Load the model
model = load_model("Flower_classification.h5")

# Flower names 
flower_names = ['daisy', 'dandelion', 'iris', 'rose', 'sunflower']

@app.post("/predict/")
async def predict(file: UploadFile = File(...)):
    # Read the image file
    image_bytes = await file.read()
    
    # Open and preprocess the image
    image = Image.open(io.BytesIO(image_bytes)).convert("RGB")
    image = image.resize((180, 180))  # Match the training image size
    image_array = np.array(image) / 255.0
    
    # Add batch dimension
    processed_image = np.expand_dims(image_array, axis=0)
    
    # Predict
    predictions = model.predict(processed_image)
    result = tf.nn.softmax(predictions[0])
    
    # Get the predicted class and confidence
    predicted_class_index = np.argmax(result)
    confidence = np.max(result) * 100
    
    return {
        "prediction": predictions.tolist(),
        "flower_name": flower_names[predicted_class_index],
        "confidence": float(confidence)
    }