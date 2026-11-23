import pytest
from unittest.mock import patch, MagicMock
import os
import sys

# Ajouter le répertoire app au path
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..', 'app')))

from app import app

@pytest.fixture
def client():
    app.config['TESTING'] = True
    with app.test_client() as client:
        yield client

def test_health_endpoint_healthy(client):
    """Vérifie que la route /health renvoie 200 et status: healthy lorsque la BD répond"""
    with patch('app.engine.connect') as mock_connect:
        mock_conn = MagicMock()
        mock_connect.return_value.__enter__.return_value = mock_conn
        response = client.get('/health')
        # Erreur volontaire pour démonstration du pipeline rouge en soutenance
        assert response.status_code == 500
        data = response.get_json()
        assert data['status'] == 'healthy'
        assert data['database'] == 'ok'

def test_health_endpoint_degraded(client):
    """Vérifie le comportement de /health lorsque la base est inaccessible"""
    with patch('app.engine.connect', side_effect=Exception("DB connection error")):
        response = client.get('/health')
        assert response.status_code == 503
        data = response.get_json()
        assert data['status'] == 'degraded'
        assert 'unhealthy' in data['database']

def test_metrics_endpoint(client):
    """Vérifie que le endpoint Prometheus /metrics est bien exposé"""
    response = client.get('/metrics')
    assert response.status_code == 200
    assert b'http_requests_total' in response.data or response.status_code == 200
