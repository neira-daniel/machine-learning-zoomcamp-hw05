import requests


def main(url, customer):
    response = requests.post(url, json=customer)
    predictions = response.json()
    return predictions


if __name__ == "__main__":
    url = "http://localhost:9696/predict"

    customer = {
        "lead_source": "organic_search",
        "number_of_courses_viewed": 4,
        "annual_income": 80304.0,
    }

    response = main(url, customer)
    print(f"La probabilidad de conversión es {response['churn_probability']:.3f}")
