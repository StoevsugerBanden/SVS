using UnityEngine;
using System.Collections;

public class CreateBody : MonoBehaviour {

    Rigidbody rb;
    //RaycastHit hit;
    float mass, drag;
    ObjectProperties op;

	void Start () {
        rb = GetComponent<Rigidbody>();
        op = GetComponent<ObjectProperties>();
        mass = op.mass;
        drag = op.drag;
        
	}
	
	void Update () {

        if (rb == null) {
            if (Physics.Raycast(transform.position, Vector3.down)) {//, out hit
                gameObject.AddComponent<Rigidbody>();
                rb = GetComponent<Rigidbody>();
                rb.drag = drag;
                rb.mass = mass;
            }

        }
	}
}
