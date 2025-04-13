from fastapi import FastAPI, UploadFile, File
from fastapi.middleware.cors import CORSMiddleware
import tensorflow as tf
from tensorflow.keras.models import load_model
from PIL import Image
import numpy as np
import io
import datetime
import traceback

app = FastAPI()

# Add CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"]
)

# Load the disease classification model
model = load_model("disease_classification.h5")

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

@app.post("/predict-disease/") 
async def predict_disease(file: UploadFile = File(...)):
    try:
        # Read the image file
        image_bytes = await file.read()
        
        # Open and preprocess the image
        image = Image.open(io.BytesIO(image_bytes)).convert("RGB")
        image = image.resize((256, 256))  # Adjust size based on your model's expected input
        image_array = np.array(image) / 255.0
        
        # Add batch dimension
        processed_image = np.expand_dims(image_array, axis=0)
        
        # Predict
        predictions = model.predict(processed_image)
        result = tf.nn.softmax(predictions[0])
        
        # Get the predicted class and confidence
        predicted_class_index = np.argmax(result)
        confidence = np.max(result) * 100
        predicted_class_name = class_names[predicted_class_index]
        
        # Split into plant type and condition (healthy/disease)
        plant_type, condition = predicted_class_name.split('___')
        
        return {
         "disease_name": predicted_class_name,  # e.g. "Tomato___Bacterial_spot"
        "plant_type": plant_type,
        "condition": condition,
        "confidence": float(confidence)
            }
    except Exception as e:
        return {
            "success": False,
            "error": str(e),
            "traceback": traceback.format_exc()  # Detailed error info
        }
    
    
# import streamlit as st
# from PIL import Image
# import numpy as np
# import tensorflow as tf

# # Load your model (adjust path as needed)
# model = tf.keras.models.load_model("disease_classification.h5")

# # Your class names (copy from diseases.py)
# class_names = {
#     0: 'Apple___Apple_scab',
#     1: 'Apple___Black_rot',
#     2: 'Apple___Cedar_apple_rust',
#     3: 'Apple___healthy',
#     4: 'Corn_(maize)___Cercospora_leaf_spot Gray_leaf_spot',
#     5: 'Corn_(maize)___Common_rust_',
#     6: 'Corn_(maize)___Northern_Leaf_Blight',
#     7: 'Corn_(maize)___healthy',
#     8: 'Grape___Black_rot',
#     9: 'Grape___Esca_(Black_Measles)',
#     10: 'Grape___Leaf_blight_(Isariopsis_Leaf_Spot)',
#     11: 'Grape___healthy',
#     12: 'Potato___Early_blight',
#     13: 'Potato___Late_blight',
#     14: 'Potato___healthy',
#     15: 'Tomato___Bacterial_spot',
#     16: 'Tomato___Leaf_Mold',
#     17: 'Tomato___Septoria_leaf_spot',
#     18: 'Tomato___healthy',
# }

# st.title("🌱 Disease Model Tester")
# st.write("Upload plant images to test model predictions")

# uploaded_file = st.file_uploader("Choose an image...", type=["jpg", "png", "jpeg"])

# if uploaded_file is not None:
#     # Display image
#     image = Image.open(uploaded_file)
#     st.image(image, caption='Uploaded Image', width=300)
    
#     # Preprocess image (match your model's expected input)
#     img_array = np.array(image.resize((256, 256))) / 255.0
#     img_array = np.expand_dims(img_array, axis=0)
    
#     # Get prediction
#     predictions = model.predict(img_array)
#     predicted_class = np.argmax(predictions[0])
#     confidence = np.max(predictions[0]) * 100
    
#     # Show results
#     st.subheader("Results")
#     st.write(f"**Predicted Disease:** {class_names[predicted_class]}")
#     st.write(f"**Confidence:** {confidence:.2f}%")
    
#     # Show raw predictions (for debugging)
#     with st.expander("See raw predictions"):
#         st.write(predictions)
#         st.write("Class mapping:", class_names)