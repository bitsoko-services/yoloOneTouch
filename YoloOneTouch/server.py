from flask import Flask, jsonify, request
from flask_cors import CORS

from flask_cors import CORS
import os
import OneTouchYolo as oty


# Instantiate our Server
app = Flask(__name__)
CORS(app)

@app.route('/status', methods=['GET'])
def status():
	response = {
		'status':oty.RUNTIME_STATUS,
		'model_name':oty.MODEL_NAME,
		'classes':oty.LABELS_COUNT,
		'data_count':oty.DATA_COUNT,
	}
	return jsonify(response),200

@app.route('/init', methods=['GET'])
def init():
	oty.main()
	response = {
		'model':'Started....',
	}
	return jsonify(response),200


if __name__ == "__main__":
	app.run(host='0.0.0.0', port=5000)