
# image to image translation

from __future__ import absolute_import
from __future__ import division
from __future__ import print_function

import tensorflow as tf
import numpy as np
import json
import base64
import cv2


def translate(model_dir,input_file,device_opt="/cpu:0"):
    with open(input_file) as f:
        input_data = f.read()

    input_instance = dict(input=base64.urlsafe_b64encode(input_data), key="0")
    input_instance = json.loads(json.dumps(input_instance))

    with tf.Session() as sess:
        with tf.device(device_opt):
            saver = tf.train.import_meta_graph(model_dir + "/export.meta")
            saver.restore(sess, model_dir + "/export")
            input_vars = json.loads(tf.get_collection("inputs")[0])
            output_vars = json.loads(tf.get_collection("outputs")[0])
            input = tf.get_default_graph().get_tensor_by_name(input_vars["input"])
            output = tf.get_default_graph().get_tensor_by_name(output_vars["output"])

            input_value = np.array(input_instance["input"])
            output_value = sess.run(output, feed_dict={input: np.expand_dims(input_value, axis=0)})[0]

    output_instance = dict(output=output_value, key="0")

    b64data = output_instance["output"].encode("ascii")
    b64data += "=" * (-len(b64data) % 4)
    output_data = base64.urlsafe_b64decode(b64data)

    #from os import path, access, R_OK  # W_OK for write permission.
    #PATH='./temp.png'
    #if path.exists(PATH) and path.isfile(PATH) and access(PATH, R_OK):
    #    print "File exists and is readable"
    #else:
    #    print "Either file is missing or is not readable"
    output_file = os.path.splitext(input_file)[0]+"_out.png"
    with open(output_file, "w") as f:
        f.write(output_data)

    return output_file
