using UnityEngine;
using System.Collections;
using Cubiquity;

public class trackingCast : MonoBehaviour {
    RaycastHit hit;
    GameObject terrain;
    ClickToCarveTerrainVolume carve;
    private TerrainVolume terrainVolume;

    int range;

    Vector3 p;

	// Use this for initialization
	void Start () {
        terrain = GameObject.FindGameObjectWithTag("ProTerrain");
        carve = terrain.GetComponent<ClickToCarveTerrainVolume>();
        terrainVolume = terrain.GetComponent<TerrainVolume>();
        range = carve.range;
	}
	
	// Update is called once per frame
	void Update () {

        // Build a ray based on the current mouse position
        Vector2 mousePos = Input.mousePosition;
        //Ray ray = Camera.main.ScreenPointToRay(new Vector3(mousePos.x, mousePos.y, 0));
        Ray ray = new Ray(transform.position, Vector3.down);
        // Perform the raycasting.
        PickSurfaceResult pickResult;
        bool hit = Picking.PickSurface(terrainVolume, ray, 1000.0f, out pickResult);

        if (hit)
        {
            carve.DestroyVoxels((int)pickResult.volumeSpacePos.x, (int)pickResult.volumeSpacePos.y, (int)pickResult.volumeSpacePos.z, range);
        }
        /* if (Physics.Raycast(transform.position, Vector3.down, out hit)) {
             print("Dig here: " + hit.point);
             p = hit.point;
             Debug.DrawRay(transform.position, Vector3.down, Color.green, 3, true);
             carve.DestroyVoxels((int)p.x, (int)p.y, (int)p.z,range);
         }*/
    }

    void SetRange(int r) {
        range = r;
    }
}
