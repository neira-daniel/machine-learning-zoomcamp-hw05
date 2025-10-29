import pickle
import sys
import hashlib


def predict(pipeline, record):
    y_pred = pipeline.predict_proba(record)[0, 1]
    return y_pred


def main(record, model_file_path, model_file_md5, model_file_url):
    try:
        with open(model_file_path, "rb") as f_in:
            data = f_in.read()
    except FileNotFoundError:
        print(f"El archivo {model_file_path} no existe")

    if md5 := hashlib.md5(data).hexdigest() != model_file_md5:
        print(f"La suma MD5 de ${model_file_path} no coincide con la esperada")
        print(f"- Obtenida: {md5}")
        print(f"- Esperada: {model_file_md5}")
        print(f"Se recomienda volver a descargar el archivo desde\n  {model_file_url}")
        sys.exit(1)

    with open(model_file_path, "rb") as f_in:
        pipeline = pickle.load(f_in)

    y_pred = predict(pipeline, record)
    print(y_pred)


if __name__ == "__main__":
    record = {
        "lead_source": "paid_ads",
        "number_of_courses_viewed": 2,
        "annual_income": 79276.0,
    }

    model_file_path = "assets/pipeline_v1.bin"
    model_file_md5 = "7d17d2e4dfbaf1e408e1a62e6e880d49"
    model_file_url = "https://github.com/DataTalksClub/machine-learning-zoomcamp/blob/4a318472ac190e98a0a35c038f12e4e536327f86/cohorts/2025/05-deployment/pipeline_v1.bin"

    main(record, model_file_path, model_file_md5, model_file_url)
