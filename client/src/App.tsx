import React, { useEffect, useState } from 'react';
import axios from 'axios';
import './App.css'; // On importe le fichier CSS externe

function App() {
  const [stations, setStations] = useState<any[]>([]);
  const [stats, setStats] = useState<any>(null);
  const [loading, setLoading] = useState<boolean>(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    // Récupération des données en parallèle
    Promise.all([
      axios.get('/api/stations'),
      axios.get('/api/stats')
    ])
      .then(([resStations, resStats]) => {
        setStations(resStations.data);
        setStats(resStats.data);
        setLoading(false);
      })
      .catch(err => {
        console.error("Erreur API:", err);
        setError("Impossible de charger les données Velib.");
        setLoading(false);
      });
  }, []);

  return (
    <div className="container">
      <header className="header">
        <h1 className="title">🚲 Velib Insights</h1>
        <p className="subtitle">Statistiques en temps réel via Kubernetes Local</p>
      </header>

      {/* SECTION STATISTIQUES (KPI) */}
      {stats && (
        <div className="stats-dashboard">
          <div className="stat-box">
            <h4>🚲 Vélos Total</h4>
            <p>{stats.vélos_disponibles_total}</p>
          </div>
          <div className="stat-box">
            <h4>📊 Remplissage</h4>
            <p>{stats.taux_remplissage_moyen}</p>
          </div>
          <div className="stat-box">
            <h4>🚨 Alerte</h4>
            <p>{stats.alerte_penurie ? "⚠️ Stock Faible" : "✅ OK"}</p>
          </div>
        </div>
      )}

      {/* ETATS DE CHARGEMENT ET ERREUR */}
      {loading && <p className="info">Chargement des données...</p>}
      {error && <div className="error-card">{error}</div>}

      {/* GRILLE DES STATIONS */}
      {!loading && !error && (
        <div className="grid">
          {stations.map((station) => (
            <div key={station.id} className="card">
              <h3 className="station-name">{station.name}</h3>
              <div className="stats-row">
                <span className="label">Vélos dispos:</span>
                <span className="value">{station.bikes}</span>
              </div>
              <div className="stats-row">
                <span className="label">Bornes libres:</span>
                <span className="value">{station.docks}</span>
              </div>

              {/* Barre de progression visuelle */}
              <div className="progress-bar-bg">
                <div
                  className="progress-bar-fill"
                  style={{ width: `${(station.bikes / station.capacity) * 100}%` }}
                />
              </div>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}

export default App;