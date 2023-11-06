# Object-Counting-Flutter-App
An Object Counting application built using Flutter, NGROK, Flask, using the YOLOv8 model from the ultralytics library. 

## Getting Started
Clone this github repo to your local system and navigate to the API folder.

## Setting Up a Virtual Environment and Installing Libraries

1. Install `virtualenv` (if not already installed)
```bash
pip install venv
```

2. Create a Virtual Environment
```bash
python3 -m venv myenv
```

3. Activate the virtual environment by running the appropriate command for your OS
```bash
source myenv/bin/activate
```

4. Once activated, install the requored libraries from the `requirements.txt` file
```bash
pip install -r requirements.txt
```
## Get started with the server side

1. Get the flask API endpoint running on your localhost 
```bash
python3 main.py
```

2. Install NGROK on your system
```bash
sudo apt install NGROK
```
3. Run the below line to create a HTTP tunnel
```bash
ngrok http 4000
```

4. Use the link obtained from above and paste it in the `main.dart` file on line 49

5. Move back to the original directory, Run your flutter project (assuming flutter is installed)
```bash
flutter run
```

All credits to the YOLOv8 creators for the pretrained yolov8 model. Find their Github @ <https://github.com/ultralytics/ultralytics>



