import express, { Request, Response } from 'express';
import axios from 'axios';
import cors from 'cors';

const app = express();
const PORT = process.env.PORT || 5000;

app.use(cors());
app.use(express.json());

const VELIB_API_URL = "https://opendata.paris.fr/api/explore/v2.1/catalog/datasets/velib-disponibilite-en-temps-reel/records?limit=20";

// Health Check pour les Liveness/Readiness probes de Kubernetes
app.get('/health', (req: Request, res: Response) => {
  res.status(200).json({ status: 'UP', timestamp: new Date().toISOString() });
});

// Endpoint 1 : Liste détaillée avec localisation
app.get('/stations', async (req: Request, res: Response) => {
  try {
    const response = await axios.get(VELIB_API_URL);
    const stations = response.data.results.map((s: any) => ({
      id: s.stationcode,
      name: s.name,
      bikes: s.numbikesavailable,
      docks: s.numdocksavailable,
      capacity: s.capacity,
      coords: { lat: s.coordonnees_geo.lat, lon: s.coordonnees_geo.lon },
      state: s.is_renting === "OUI" ? "En service" : "Maintenance"
    }));
    res.json(stations);
  } catch (error) {
    res.status(500).json({ error: "Erreur OpenData" });
  }
});

// Endpoint 2 : Statistiques Globales (Valeur ajoutée !)
app.get('/stats', async (req: Request, res: Response) => {
  try {
    const response = await axios.get(VELIB_API_URL);
    const results = response.data.results;

    const totalBikes = results.reduce((acc: number, s: any) => acc + s.numbikesavailable, 0);
    const totalDocks = results.reduce((acc: number, s: any) => acc + s.numdocksavailable, 0);
    const saturationRate = ((totalBikes / (totalBikes + totalDocks)) * 100).toFixed(2);

    res.json({
      total_stations_analysees: results.length,
      vélos_disponibles_total: totalBikes,
      bornes_libres_total: totalDocks,
      taux_remplissage_moyen: `${saturationRate}%`,
      alerte_penurie: totalBikes < 50 ? true : false
    });
  } catch (error) {
    res.status(500).json({ error: "Erreur lors du calcul des stats" });
  }
});

app.listen(PORT, () => {
  console.log(`🚀 Server running on http://localhost:${PORT}`);
});