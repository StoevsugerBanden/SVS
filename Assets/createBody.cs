using UnityEngine;
using System.Collections;

public class createBody : MonoBehaviour {

    Rigidbody rb;
    RaycastHit hit;
    float mass, drag;
    objectProperties op;

	void Start () {
        rb = GetComponent<Rigidbody>();
        op = GetComponent<objectProperties>();
        mass = op.mass;
        drag = op.drag;
        
	}
	
	void Update () {
        if (rb == null) {
            if (Physics.Raycast(transform.position, Vector3.down, out hit)){
                print("Found an object - distance: " + hit.distance + " " + hit.transform);
                gameObject.AddComponent<Rigidbody>();
                rb = GetComponent<Rigidbody>();
                rb.drag = drag;
                rb.mass = mass;
            }

        }
	}
}
