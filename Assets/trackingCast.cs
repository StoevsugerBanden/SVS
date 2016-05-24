using UnityEngine;
using System.Collections;

public class trackingCast : MonoBehaviour {
    RaycastHit hit;
    GameObject terrain;
    ClickToCarveTerrainVolume carve;

    int range;

    Vector3 p;

	// Use this for initialization
	void Start () {
        terrain = GameObject.FindGameObjectWithTag("ProTerrain");
        carve = terrain.GetComponent<ClickToCarveTerrainVolume>();
        range = carve.range;
	}
	
	// Update is called once per frame
	void Update () {
        if (Physics.Raycast(transform.position, Vector3.down, out hit)) {
            print("Dig here: " + hit.point);
            p = hit.point;
            //Debug.DrawLine(hit.transform.position, Vector3.up, Color.green);
            carve.DestroyVoxels((int)p.x, (int)p.y, (int)p.z,range);
        }
	}
}
