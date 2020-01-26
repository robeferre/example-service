package hello;

import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.bind.annotation.RequestMapping;

@RestController
public class HelloController {

    @RequestMapping("/")
    public String index() {
        String envData = System.getenv("ENV");
        return String.format("Hi you are on %s environment!",envData);
    }
}
