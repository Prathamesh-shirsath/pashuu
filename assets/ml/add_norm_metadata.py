"""
add_norm_metadata.py
Adds NormalizationOptions metadata to a TFLite model
so that ML Kit can preprocess float32 image input correctly.
"""

import sys
from tflite_support.metadata_writers import image_classifier
from tflite_support.metadata_writers import writer_utils

def add_metadata(model_file, label_file, output_file):
    # Normalization options — most image models trained with [-1,1] normalization
    mean = [127.5]
    std = [127.5]

    # Create metadata writer
    writer = image_classifier.MetadataWriter.create_for_inference(
        writer_utils.load_file(model_file),
        [mean],
        [std],
        label_file
    )

    # Write metadata to new file
    writer_utils.save_file(writer.populate(), output_file)
    print(f"✅ Metadata added successfully!\nInput model: {model_file}\nOutput model: {output_file}")

if __name__ == "__main__":
    if len(sys.argv) != 4:
        print("Usage: py add_norm_metadata.py <model.tflite> <labels.txt> <output_model.tflite>")
        sys.exit(1)

    model_file = sys.argv[1]
    label_file = sys.argv[2]
    output_file = sys.argv[3]

    add_metadata(model_file, label_file, output_file)
