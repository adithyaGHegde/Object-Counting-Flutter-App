import cv2
import argparse
import numpy as np
from ultralytics import YOLO
import supervision as sv
from flask import Flask, request, jsonify, send_file
import json

bbox = np.array([
    [0, 0],
    [0.5, 0],
    [0.5, 1],
    [0, 1]
])

directory = ""

def main(image_path):
    model = YOLO("yolov8l.pt")

    annotation_box = sv.BoxAnnotator(
        thickness=2,
        text_thickness=2,
        text_scale=1
    )

    bbox = (bbox * np.array([1280, 720])).astype(int)
    zone = sv.PolygonZone(polygon=bbox, frame_resolution_wh=(1280, 720))
    zone_annotator = sv.PolygonZoneAnnotator(
        zone=zone,
        color=sv.Color.red(),
        thickness=2,
        text_thickness=4,
        text_scale=2
    )

    frame = cv2.imread(image_path)
    frame = cv2.resize(frame, (1280, 720))
    result = model(frame, agnostic_nms=True)[0]
    detections = sv.Detections.from_yolov8(result)

    labels = [
        f"{model.model.names[class_id]} {confidence:0.2f}"
        for _, confidence, class_id, _
        in detections
    ]
    frame = annotation_box.annotate(
        scene=frame,
        detections=detections,
        labels=labels
    )
    zone.trigger(detections=detections)

    frame = zone_annotator.annotate(scene=frame)
    cv2.imwrite("output.jpg", frame)
    cv2.waitKey(0)
    cv2.destroyAllWindows()

    detected_objects = [f"{model.model.names[class_id]} {confidence:0.2f}" for _, confidence, class_id, _ in detections]
    annotated_boxes = [box.tolist() if box is not None else [] for _, _, _, box in detections]
    
    return len(detections), detected_objects, annotated_boxes

app = Flask(__name__)

@app.route("/upload", methods=["POST"])
def files():
    uploaded = request.files['image']
    if uploaded.filename != '':
        uploaded.save(uploaded.filename)
    num_objects_detected, detected_objects = main(uploaded.filename)
    
    
    response = {
        "num_objects_detected": num_objects_detected,
        "detected_objects": detected_objects,
        "annotated_boxes": annotated_boxes
    }
    return jsonify(response)

if __name__ == "__main__":
    app.run(debug=True, port=4000)
