using UnityEngine;
using System.Collections;

public class loadTimer : MonoBehaviour {

    public float time = 5;
	
	// Update is called once per frame
	void Update () {
        time -= Time.deltaTime;
        if (time <= 0)
        {
            print("loading screen done");
            gameObject.SetActive(false);
        }
	}
}
